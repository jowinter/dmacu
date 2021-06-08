#!/usr/bin/env python3
#
# Translate movfuscator output into DMA based operations.
#
# We assume that the input program has been assembled as:
#   > movcc -S -Wf--no-mov-flow -Wf--no-mov-extern -Wf--no-mov-loop movme.c
#

import argparse
import logging
import re
import sys
import os


#--------------------------------------------------------------------------------------------------
class CpuRegInfo:
    def __init__(self, name, size, asm_name, asm_offset, is_alias = False):
        self._name       = str(name)
        self._size       = int(size)
        self._asm_name   = str(asm_name)
        self._asm_offset = int(asm_offset)
        self._is_alias   = is_alias

    def __repr__(self):
        return self._name

    @property
    def name(self):
        return self._name

    @property
    def size(self):
        return self._size

    @property
    def asm_name(self):
        return self._asm_name
        
    @property
    def asm_offset(self):
        return self._asm_offset

    @property
    def is_alias(self):
        return self._is_alias

# Well-known CPU registers
WELL_KNOWN_CPU_REGS = {
    'al' : CpuRegInfo(name = 'al',   asm_name = '.L__movme.reg.eax', asm_offset = 0, size = 1, is_alias = True),
    'ah' : CpuRegInfo(name = 'ah',   asm_name = '.L__movme.reg.eax', asm_offset = 1, size = 1, is_alias = True),
    'bl' : CpuRegInfo(name = 'bl',   asm_name = '.L__movme.reg.ebx', asm_offset = 0, size = 1, is_alias = True),
    'bh' : CpuRegInfo(name = 'bh',   asm_name = '.L__movme.reg.ebx', asm_offset = 1, size = 1, is_alias = True),
    'cl' : CpuRegInfo(name = 'cl',   asm_name = '.L__movme.reg.ecx', asm_offset = 0, size = 1, is_alias = True),
    'ch' : CpuRegInfo(name = 'cl',   asm_name = '.L__movme.reg.ecx', asm_offset = 1, size = 1, is_alias = True),
    'dl' : CpuRegInfo(name = 'dl',   asm_name = '.L__movme.reg.edx', asm_offset = 0, size = 1, is_alias = True),
    'dh' : CpuRegInfo(name = 'dh',   asm_name = '.L__movme.reg.edx', asm_offset = 1, size = 1, is_alias = True),

    'ax' : CpuRegInfo(name = 'ax',   asm_name = '.L__movme.reg.eax', asm_offset = 0, size = 2, is_alias = True),
    'bx' : CpuRegInfo(name = 'bx',   asm_name = '.L__movme.reg.ebx', asm_offset = 0, size = 2, is_alias = True),
    'cx' : CpuRegInfo(name = 'cx',   asm_name = '.L__movme.reg.ecx', asm_offset = 0, size = 2, is_alias = True),
    'dx' : CpuRegInfo(name = 'dx',   asm_name = '.L__movme.reg.edx', asm_offset = 0, size = 2, is_alias = True),

    'eax' : CpuRegInfo(name = 'eax', asm_name = '.L__movme.reg.eax', asm_offset = 0, size = 4),
    'ebx' : CpuRegInfo(name = 'ebx', asm_name = '.L__movme.reg.ebx', asm_offset = 0, size = 4),
    'ecx' : CpuRegInfo(name = 'ecx', asm_name = '.L__movme.reg.ecx', asm_offset = 0, size = 4),
    'edx' : CpuRegInfo(name = 'edx', asm_name = '.L__movme.reg.edx', asm_offset = 0, size = 4)
}

#--------------------------------------------------------------------------------------------------
# Operand expression of a move instruction.
#

class Operand:
    def __init__(self, size):
        self._size = size

    def visit(self, visitor):
        raise NotImplementedError()

    @property
    def size(self):
        return self._size

    def emit(self, cg, tgt, is_load):
        raise NotImplementedError()

class OpImm(Operand):
    """
    Immediate expression
    """

    def __init__(self, imm, size):
        super().__init__(size = size)

        self._imm = str(imm)

    def __repr__(self):
        return ('imm.%u(%s)' % (self.size, self.imm))

    def visit(self, visitor):
        return visitor.imm(self)

    @property
    def imm(self):
        return self._imm

    def emit(self, cg, tgt, is_load):
        if is_load:
            # Load
            lbl = cg.make_constant(self.imm)
            cg.copy(v_dst = tgt, v_src = lbl, size = self.size)

        else:
            # Save
            raise ValueError('Cannot store to a literal')

class OpReg(Operand):
    """
    Register access expression
    """

    def __init__(self, reg):
        # Resolve a well-known X86 register
        info = WELL_KNOWN_CPU_REGS[str(reg)]

        super().__init__(info.size)        
        self._info = info


    def __repr__(self):
        return ('reg.%u(%s)' % (self.size, self.info.name))

    def visit(self, visitor):
        return visitor.reg(self)

    @property
    def info(self):
        return self._info

    def emit(self, cg, tgt, is_load):
        if is_load:
            # Load
            cg.reg_load(v_dst = tgt, reg = self.info)

        else:
            # Save
            cg.reg_store(v_src = tgt, reg = self.info)

class OpAddExpr(Operand):
    """
    Add operand expressions
    """

    def __init__(self, left, right, size):
        super().__init__(size)

        self._left = left
        self._right = right

    def __repr__(self):
        return ('add.%u(%s,%s)' % (self.size, self.left, self.right))

    def visit(self, visitor):
        return visitor.add(self)

    @property
    def size(self):
        return self._size

    @property
    def left(self):
        return self._left

    @property
    def right(self):
        return self._right

    def emit(self, cg, tgt, is_load):
        # Generate the LHS and RHS operands
        if is_load:
            # Load

            # Generate the LHS expression
            v_left  = cg.imm_alloc(self.left)
            
            # Generate the RHS expression
            v_right = cg.imm_alloc(self.right)
            
            # Load
            cg.add(v_dst = tgt, v_left = v_left, v_right = v_right)

            cg.imm_release(v_right)
            cg.imm_release(v_left)
        else:
            # Save
            raise ValueError('Cannot store to an RHS expression (add)')

class OpScaleExpr(Operand):
    """
    Scale operation
    """

    def __init__(self, arg, scale, size):
        super().__init__(size)

        self._arg = arg
        self._scale = int(scale)

    def __repr__(self):
        return ('scale.%u(%s,%u)' % (self.size, self.arg, self.scale))

    def visit(self, visitor):
        return visitor.scale(self)

    def rewrite(self, visitor):
        self._arg  = self._arg.visit(self._arg)
        return self.visit(self)

    @property
    def arg(self):
        return self._arg

    @property
    def scale(self):
        return self._scale

    def emit(self, cg, tgt, is_load):
        if is_load:
            # Load

            # Generate the operand expression
            v_arg  = cg.imm_alloc(self.arg)
            
            # Load
            cg.scale(v_dst = tgt, v_arg = v_arg, scale = self.scale)

            cg.imm_release(v_arg)
        else:
            # Save
            raise ValueError('Cannot store to an RHS expression (add)')


class OpMemExpr(Operand):
    """
    Memory operand
    """

    def __init__(self, addr, size):
        super().__init__(size)

        self._addr = addr

    def __repr__(self):
        return ('mem.%u(%s)' % (self.size, self.addr))

    def visit(self):
        return visitor.mem(self)

    def rewrite(self, visitor):
        self._addr  = self._arg.visit(self._addr)
        return self.visit(self)

    @property
    def addr(self):
        return self._addr

    def emit(self, cg, tgt, is_load):
        # Generate the address expression
        v_addr = cg.imm_alloc(self.addr)

        if is_load:
            cg.mem_load(v_dst = tgt, v_addr = v_addr, size = self.size)            
        else:
            cg.mem_store(v_src = tgt, v_addr = v_addr, size = self.size)

        cg.imm_release(v_addr)

#--------------------------------------------------------------------------------------------------
# Code generator context
#
class CodeGenerator:
    def __init__(self):
        # Maps from constants to their labels
        self._constants = {}
        self._next_cp_index = 0
        self._next_lli = 0

        # Temporary variable pool
        self._temps_alloc    = {}
        self._temps_active   = {}
        
        self._code = []
        pass

    def make_constant(self, lit):
        """
        Generates an immediate expression in constant memory (and returns the assembler label)
        """
        lit = str(lit)

        if lit in self._constants:
            # Constant already exists in our pool
            return self._constants[lit]

        # Create a fresh pool entry
        label = (".L__movme_cp.%u" % self._next_cp_index)

        self._constants[lit] = label
        self._next_cp_index += 1
        return label

    def alloc(self):
        """
        Allocates a temporary variable
        """

        idx = 0

        # Record as active and as allocated
        while (".L__movme_tmp.%u" % idx) in self._temps_active:
            idx += 1

        lbl = (".L__movme_tmp.%u" % idx)
        self._temps_active[lbl] = True
        self._temps_alloc[lbl]  = True
        return lbl

    def release(self, lbl):
        """
        Releases a temporary variable
        """
        del self._temps_active[lbl]

    def move(self, dst, src):
        """
        Generate a MOV instruction
        """

        v_tmp = self.alloc()

        # Load the source operand
        src.emit(self, v_tmp, True)

        # And store to the target operand
        dst.emit(self, v_tmp, False)

        self.release(v_tmp)

    def pc_label(self, pos):
        return (".L__pc.%u" % pos)

    def make_pc_labels(self):
        this_label = self.pc_label(self._next_lli)
        self._next_lli += 1
        next_label = self.pc_label(self._next_lli)
        return (this_label, next_label)

    def bad_access(self):
        return "__movme.bad"

    def emit(self, line, *args):
        self._code.append("\t" + (line % args).strip())

    def label(self, label):
        self.emit("// LABEL %s", label)
        self.emit("%s:", label)
        self.emit('')

    def emit_globals(self):                
        self.emit('.pushsection ".data", "aw", "progbits"')
        self.emit('.p2align 2')
        self.emit('')
        self.emit('// Register block')
        for (_,reg) in WELL_KNOWN_CPU_REGS.items():
            if not (reg.is_alias):
                self.emit('%s: .fill %u', reg.asm_name, reg.size)
        self.emit('')
        self.emit('// Temporary variables')
        self.emit('.pushsection ".data", "aw", "progbits"')
        self.emit('.p2align 2')
        self.emit('')
        for tmp in self._temps_alloc:
            self.emit('%s: .fill 4', tmp)
        self.emit('.popsection')
        self.emit('')

        self.emit('// Constant pool')
        self.emit('.pushsection ".rodata", "a", "progbits"')
        self.emit('.p2align 2')

        for (imm,name) in self._constants.items():
            self.emit("%s: .long (%s)", name, imm)

        self.emit('.popsection')
        self.emit('')

        self.emit('// Bad access trap')
        self.emit('.set %s, 0x0BADC0DE', self.bad_access())
        self.emit('.set %s, 0x0BADC1DE', self.pc_label(self._next_lli))

    def copy(self, v_dst, v_src, size):
        """
        Copies 'size' bytes from 'v_src' to 'v_dst'.
        
        'v_src' and 'v_dst' must be temporary labels
        """

        (this_label, next_label) = self.make_pc_labels()
        self.emit("// CG.COPY%u %s => %s", size, v_src, v_dst)
        self.emit("%s: Dma_ByteCopy (%s), (%s), %u, %s", this_label, v_dst, v_src, size, next_label)
        self.emit("")

    def reg_name(self, reg):
        return ("(%s+%u)" % (reg.asm_name, reg.asm_offset))

    def reg_load(self, v_dst, reg):
        v_reg = self.reg_name(reg)

        # And load the bottom
        (this_label, next_label) = self.make_pc_labels()
        self.emit(".p2align 4")
        self.emit("%s: Dma_ByteCopy (%s), (%s), %u, %s", this_label, v_dst, v_reg, reg.size, next_label)
        self.emit("")

    def reg_store(self, v_src, reg):
        v_reg = self.reg_name(reg)

        self.emit("// CG.REG.STORE%u %s => %s" % (reg.size, v_src, v_reg))
        self.emit(".p2align 4")

        # TODO: Handle half writes
        if reg.size < 4:
            reg_zero_offset = reg.asm_offset + reg.size
            reg_zero_size   = 4 - reg_zero_offset
            (this_label, next_label) = self.make_pc_labels()
            self.emit("%s: Dma_ByteCopy (%s+%u), (%s), %u, %s", this_label, v_reg, reg.size,
                self.make_constant(0), reg_zero_size, next_label)
        
        (this_label, next_label) = self.make_pc_labels()
        self.emit("%s: Dma_ByteCopy (%s), (%s), %u, %s", this_label, v_reg, v_src, reg.size, next_label)
        self.emit("")
        

    def add(self, v_dst, v_left, v_right):
        logging.info("CG.ADD %s + %s => %s" % (v_left, v_right, v_dst))

    def scale(self, v_dst, v_arg, scale):
        logging.info("CG.SCALE %s * %u => %s" % (v_arg, scale, v_dst))

    def mem_load(self, v_dst, v_addr, size):
        (this_label, next_label) = self.make_pc_labels()
        load_label = this_label + ".LD"

        self.emit("// CG.LOAD%u [%s} => %s" % (size, v_addr, v_dst))
        self.emit(".p2align 4")
        self.emit("%s: Dma_PatchSrc (%s), (%s), (%s)",   this_label, load_label, v_addr, load_label)
        self.emit("%s: Dma_ByteCopy (%s), (%s), %u, %s", load_label, v_dst,  self.bad_access(), size, next_label)
        self.emit("")

    def mem_store(self, v_addr, v_src, size):
        (this_label, next_label) = self.make_pc_labels()
        store_label = this_label + ".ST"

        self.emit(".p2align 4")
        self.emit("%s: Dma_PatchDst (%s), (%s), (%s)",   this_label, store_label, v_addr, store_label)
        self.emit("%s: Dma_ByteCopy (%s), (%s), %u, %s", store_label, self.bad_access(), v_src, size, next_label)
        self.emit("")

    def imm_alloc(self, imm):
        if isinstance(imm, OpImm):
            # We have an immediate operand, no need to create a temporary variable
            return self.make_constant(imm.imm)

        elif isinstance(imm, OpReg):
            # We have a register operand, no need to create a temporary variable
            return self.reg_name(imm.info)


        else:
            # Allocate a temporary
            v_tmp = self.alloc()
            imm.emit(cg = self, tgt = v_tmp, is_load = True)
            return v_tmp

    def imm_release(self, v_imm):
        if v_imm in self._temps_active:
            # Release our temporary
            self.release(v_imm)

#--------------------------------------------------------------------------------------------------
class MovToDmaTranspiler:
    def __init__(self):
        self._parsers = [
            # MOV instruction (regex based on movfuscator post-processing tools)
            (
                re.compile(r'^mov([bwl])\s+(.*)\s*,\s*(.*).*$'),
                self._parse_mov
            ),

            # CMP instruction
            (
                re.compile(r'^cmp([bwl])\s+(.*)\s*,\s*(.*).*$'),
                self._parse_cmp
            ),

            # Conditional JMP instruction
            (
                re.compile(r'^(j(?:e|ne|a|b))\s+(.*)$'),
                self._parse_cond_jmp,
            ),

            # JMP instruction
            (
                re.compile(r'^jmp\s+(.*)$'),
                self._parse_jmp
            ),

            # Label
            (
                re.compile(r'^([^:]+):$'),
                self._parse_label
            ),

            # Byte/Long data directive
            (
                re.compile(r'^\.(byte|long)\s+(.*)$'),
                self._parse_data
            ),

            # Section directive (well-known section)
            (
                re.compile(r'^(\.(?:data|text))$'),
                self._parse_section
            ),

            # .globl/.global directive
            (
                re.compile(r'^(?:\.globl|\.global)\s+(.*)$'),
                self._parse_global
            ),

            # .type directive
            (
                re.compile(r'^\.type\s+(.*)\s*,\s*(.*)$'),
                self._parse_type
            ),

            # .size directive
            (
                re.compile(r'^\.size\s+(.*)\s*,\s*(.*)$'),
                self._parse_size
            ),

            # User-provided section
            (
                re.compile(r'^\.section\s+(.*)$'),
                self._parse_section
            )
        ]

        # Operand parsers
        self._op_parsers = [
            # Offset, Base, Index and Scale
            (
                re.compile(r'^(.*)\(%(.*),%(.*),(.*)\)$'),
                lambda m,access_size: self._parse_op_indirect(m.group(1),m.group(2),m.group(3),int(m.group(4),0),access_size)
            ),

            # Offset, Index and Scale
            (
                re.compile(r'^(.*)\(,%(.*),(.*)\)$'),
                lambda m,access_size: self._parse_op_indirect(m.group(1),None,m.group(2),int(m.group(3),0),access_size)
            ),

            # Offset, Base and Index
            (
                re.compile(r'^(.*)\(%(.*),%(.*)\)$'),
                lambda m,access_size: self._parse_op_indirect(m.group(1),m.group(2),m.group(3),1,access_size)
            ),

            # Offset, Base and Index
            (
                re.compile(r'^(.*)\(%(.*)\)$'),
                lambda m,access_size: self._parse_op_indirect(m.group(1),m.group(2),None,1,access_size)
            ),

            # Base (register operand)
            (
                re.compile(r'^\(%(.*)\)$'),
                lambda m,access_size: self._parse_op_indirect(None,m.group(1),None,None,1,access_size)
            ),

            # Offset (direct memory reference)
            (
                re.compile(r'^\((.*)\)$'),
                lambda m,access_size: self._parse_op_indirect(m.group(1),None,None,1,access_size)
            ),

            # Literal operand
            (
                re.compile(r'^\$(.+)$'),
                lambda m,access_size: self._parse_op_lit(m, access_size)
            ),

            # Register operand
            (
                re.compile(r'^%(.+)$'),
                lambda m,access_size:  self._parse_op_reg(m, access_size)
            )
        ]

        # Operation sizes (suffix)
        self._op_sizes = {
            'b' : 1,
            'w' : 2,
            'l' : 4
        }

        # Code generator
        self._cg = CodeGenerator()

        self._parser_errors = 0
        self._reset_parser()

    def parse(self, filename):
        try:
            self._reset_parser(filename)
            with open(filename, 'rt') as f:
                for line in f:
                    self._parse_line(line)
        finally:
            self._reset_parser()

    def _reset_parser(self, input_name=None):
        self._section = None
        self._input_name = input_name
        self._line_no = 0

    def _parse_line(self, line):
        # Increment the current line number
        self._line_no += 1

        # Normalize the line (strip leading/trailing space and comments)
        line = re.sub('#.*', '', line).strip()
        if len(line) == 0:
            return

        # Walk through our line parsers
        for (matcher, handler) in self._parsers:
            m = matcher.search(line)
            if m:
                handler(m)
                return

        # Nothing matched
        self.parse_unhandled(line)

    def _parse_operand(self, op, access_size):
        for (pattern, handler) in self._op_parsers:
            m = pattern.match(op)
            if m:
                return handler(m, access_size)

        logging.error('%s(%u): unhandled operand: %s', self._input_name, self._line_no, op)
        self._parser_errors += 1
        return None

    def _parse_op_indirect(self, offset, base, index, scale, access_size):
        # An address is formed as base-reg + index-reg*scale + offset
        #
        # base-reg and index-reg are assumed as zero (if not given)

        # Immediate expression for offset
        if offset:
            expr = OpImm(imm = offset, size = 4)
        else:
            expr = None

        # Base expression
        if base:
            base = OpReg(reg = base)
            # TBD: Zero extend base if needed
            expr = OpAddExpr(left = expr, right = base, size = 4) if not (expr is None) else base

        # Index expression
        if index:
            index = OpReg(reg = index)
            # TBD: Zero extend index if needed
            if (scale != 1):
                index = OpScaleExpr(arg = index, scale = scale, size = 4)

            expr = OpAddExpr(left = expr, right = index, size = 4) if not (expr is None) else index

        return OpMemExpr(addr = expr, size = 4)


    def _parse_op_reg(self, m, access_size):
        # TODO: Check register access size?
        return OpReg(reg = m.group(1))

    def _parse_op_lit(self, m, access_size):
        return OpImm(imm = m.group(1), size = access_size)

    def _parse_access_size(self, size):
        size = str(size)
        if not (size in self._op_sizes):
            logging.error('%s(%u): unrecognized access size suffix ".%s"', self._input_name, self._line_no, size)
            self._parser_errors += 1

            # Assume byte access for error handling
            return 1

        else:
            return self._op_sizes[size]

    def _parse_mov(self, m):
        opsize = self._parse_access_size(m.group(1))
        src = self._parse_operand(m.group(2), opsize)
        dst = self._parse_operand(m.group(3), opsize)
        logging.info('MOV.%s %s := %s', opsize, dst, src)
        
        self._cg.move(src = src, dst = dst)
        pass

    def _parse_cmp(self, m):
        opsize = self._parse_access_size(m.group(1))
        lhs = self._parse_operand(m.group(2), opsize)
        rhs = self._parse_operand(m.group(3), opsize)
        logging.debug('CMP.%s %s ?= %s', opsize, lhs, rhs)

        # TODO: Generate lhs address and rhs address
        # TODO: Load from lhs => tmp1
        # TODO: Load from rhs => tmp2
        # TODO: Run compare chain (to generate flags)
        pass

    def _parse_jmp(self, m):
        tgt = m.group(1)
        # TODO: Generate branch target
        logging.debug('JMP %s', tgt)
        pass

    def _parse_cond_jmp(self, m):
        relop = m.group(1)
        tgt = m.group(2)

        # TODO: Generate relop (based on flags)
        # TODO: Generate branch target
        logging.debug('COND JMP %s TO %s', relop, tgt)
        pass

    def _parse_label(self, m):
        tgt = m.group(1)

        if tgt == "main":
            tgt = "Dma_UCode_Main"
        
        self._cg.label(tgt)

    def _parse_data(self, m):
        type = m.group(1)
        data = m.group(2)
        
        # TODO: Cleanup
        self._cg.emit("// DATA %s %s", type, data)
        self._cg.emit(".%s %s", type, data)
        self._cg.emit("")

    def _parse_global(self, m):
        sym = m.group(1)

        if sym == "main":
            sym = "Dma_UCode_Main"
        
        # TODO: Cleanup
        self._cg.emit("// GLOBAL %s", sym)
        self._cg.emit(".global %s", sym)
        self._cg.emit("")
        pass

    def _parse_type(self, m):
        sym = m.group(1)
        type = m.group(2)
        logging.debug('TYPE %s %s', sym, type)
        pass

    def _parse_size(self, m):
        sym = m.group(1)
        value = m.group(2)
        logging.debug('SIZE %s %s', sym, value)
        pass

    def _parse_section(self, m):
        name = m.group(1)
        logging.debug('SECTION %s', name)
        pass

    def _parse_unhandled(self, line):
        # Report an error
        logging.error('%s(%u): unhandled assembler instruction or directive: %s', self._input_name, self._line_no, line)
        self._parser_errors += 1

    @property
    def parser_errors(self):
        return self._parser_errors

#--------------------------------------------------------------------------------------------------
DMACU_PREFIX = """
	/**
     * Auto-generated by moveme-dma.py
	 *
	 * This file is licensed under the MIT License. See LICENSE in the root directory
	 * of the prohect for the license text.
	 */

	/* Emit a DMA descriptor for a byte copy operation */
	.macro Dma_ByteCopy dst, src, size, lli
	.long (\src)
	.long (\dst)
	.long (\lli)
	.long (0x0C000000 + \size)
	.endm

	/* Emit a DMA descriptor for a byte fill operation */
	.macro Dma_ByteFill dst, src, size, lli
	.long (\src)
	.long (\dst)
	.long (\lli)
	.long (0x08000000 + \size)
	.endm

	/* Patch srcaddr[7:0] of the descriptor given by dst */
	.macro Dma_PatchSrcLo8 dst, src, lli
	Dma_ByteCopy (\dst+0), (\src), 1, \lli
	.endm

	/* Patch srcaddr[15:8] of the descriptor given by dst */
	.macro Dma_PatchSrcHi8 dst, src, lli
	Dma_ByteCopy (\dst+1), (\src), 1, \lli
	.endm

	/* Patch srcaddr[15:0] of the descriptor given by dst */
	.macro Dma_PatchSrcLo16 dst, src, lli
	Dma_ByteCopy (\dst+0), (\src), 2, \lli
	.endm

	/* Patch srcaddr[31:16] of the descriptor given by dst */
	.macro Dma_PatchSrcHi16 dst, src, lli
	Dma_ByteCopy (\dst+2), (\src), 2, \lli
	.endm

	/* Patch dstaddr[7:0] of the descriptor given by dst */
	.macro Dma_PatchDstLo8 dst, src, lli
	Dma_ByteCopy (\dst+4), (\src), 1, \lli
	.endm

	/* Patch dstaddr[15:0] of the descriptor given by dst */
	.macro Dma_PatchDstHi8 dst, src, lli
	Dma_ByteCopy (\dst+5), (\src), 1, \lli
	.endm

	/* Patch dstaddr[15:0] of the descriptor given by dst */
	.macro Dma_PatchDstLo16 dst, src, lli
	Dma_ByteCopy (\dst+4), (\src), 2, \lli
	.endm

	/* Patch dstaddr[31:16] of the descriptor given by dst */
	.macro Dma_PatchDstHi16 dst, src, lli
	Dma_ByteCopy (\dst+6), (\src), 2, \lli
	.endm

	/* Patch the destination location */
	.macro Dma_PatchDst dst, src, lli
	Dma_ByteCopy (\dst+4), (\src), 4, \lli
	.endm

	/* Patch the source location */
	.macro Dma_PatchSrc dst, src, lli
	Dma_ByteCopy (\dst+0), (\src), 4, \lli
	.endm

    /* Virtual register file */
    .data
    .p2align 4

    /* Assume data segment by default -*/
    .data
"""

#--------------------------------------------------------------------------------------------------
def parseCmdLine():
    parser = argparse.ArgumentParser(description = "movfuscator to PL080 DMA translation")
    parser.add_argument('--input',  required=True, type=str, help='Input assembly file produced by movfuscator')
    parser.add_argument('--output', required=True, type=str, help='Output assembly file produced by movme-dma')
    parser.add_argument('--verbose', action='store_true', help='Enable verbose log output')
    return parser.parse_args()

def main():
    args = parseCmdLine()
    if args.verbose:
        logging.basicConfig(level=logging.DEBUG)
    else:
        logging.basicConfig(level=logging.INFO)

    transpiler = MovToDmaTranspiler()

    # Parse the input file
    transpiler.parse(filename = args.input)
    if (transpiler.parser_errors > 0):
        logging.error("%u parser error(s) detected while processing the input file.", transpiler.parser_errors)
        sys.exit(-1)


    transpiler._cg.emit_globals()

    with open(args.output, 'wt') as f:
        print (DMACU_PREFIX, file = f)

        for line in transpiler._cg._code:
            print (line, file = f)
        del f

    # Now do the main processing
    logging.info('processing done')
    pass

if __name__ == "__main__":
    main()
