/**
 * PoC virtual CPU implementation for the ARM PL080 DMA Controller.
 *
 * Copyright (c) 2019-2022 Johannes Winter <jrandom@speed.at>
 *
 * This file is licensed under the MIT License. See LICENSE in the root directory
 * of the project for the license text.
 */

/**
 * @file dmacu.h
 * @brief Virtual CPU emulator core (PL080 backend)
 */
#ifndef DMACU_H_
#define DMACU_H_ 1

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>

// Quiet mode
#if !defined(DMACU_QUIET)
# define DMACU_QUIET (0)
#endif

#ifndef DMACU_ALIGNED
# define DMACU_ALIGNED(x) __attribute__((__aligned__((x))))
#endif

#ifndef DMACU_PRIVATE
# define DMACU_PRIVATE
#endif

#ifndef DMACU_PRIVATE_DECL
# define DMACU_PRIVATE_DECL extern
#endif


#ifndef DMACU_CONST
# define DMACU_CONST const
#endif

#ifndef DMACU_READONLY
# define DMACU_READONLY const
#endif

#ifndef DMACU_READWRITE
# define DMACU_READWRITE
#endif

/// \brief 32-bit pointer type for the virtual CPU emulator.
///
typedef uint32_t Dma_UIntPtr_t;

/// \brief PL080 DMA descriptor
///
/// \note See the PL080 DMA controller datasheet for details on the fields of the
///    structure.
///
typedef struct Dma_Descriptor
{
    Dma_UIntPtr_t src; ///!< Source address of the transfer
    Dma_UIntPtr_t dst; ///!< Destination address of the transfer
    Dma_UIntPtr_t lli; ///!< Address of the next transfer in the chain
    uint32_t ctrl;     ///!< Control bits and transfer size
} Dma_Descriptor_t;

/// \brief Converts a C pointer to a 32-bit DMA address.
///
/// \param p is the pointer-typed C expresion to be converted.
/// \return The raw address as (unsigned) 32-bit integer of type @ref Dma_UIntPtr_t.
///
#define Dma_PtrToAddr(p) ((Dma_UIntPtr_t) (p))

/// \brief Gets the offset of field @p _field in type @p _type.
///
/// \param _type is a compound type (struct).
///
/// \param _field is the
#define Dma_OffsetOf(_type,_field) ((uint32_t) offsetof(_type, _field))

/// \brief Canonical invalid (NULL) pointer
///
#define DMA_INVALID_ADDR Dma_PtrToAddr(NULL)

//-------------------------------------------------------------------------------------------------
// Basic DMA descriptors (PL080)
//

/// \brief Defines an externally visible DMA descriptor
#define Dma_Define_Descriptor(_self,...) \
    DMACU_ALIGNED(16u) \
    DMACU_PRIVATE Dma_Descriptor_t _self = { __VA_ARGS__ };

/// \brief Constructs the name of a local descriptor or object.
#define Dma_Local_Name(_self,_suffix) \
    _self##_##_suffix

/// \brief (Re-)declares an externally visible DMA descriptor
#define Dma_Declare_Descriptor(_self) \
    DMACU_PRIVATE_DECL Dma_Descriptor_t _self;

/// \brief (Re-)declares a local DMA descriptor
#define Dma_Declare_Local_Descriptor(_self,_suffix) \
    DMACU_PRIVATE_DECL Dma_Descriptor_t Dma_Local_Name(_self,_suffix);

/// \brief References a declared descriptor
#define Dma_Local_Reference(_self,_suffix) \
    (&Dma_Local_Name(_self, _suffix))

/// \brief Common DMA copy core operation
///
/// Copies "size" bytes from "src" to "dst". Then links to the next descriptor at "lli".
///
/// width indicates the source/destination transfer width in PL080's log-2 encoding:
///  - width=0 generates a byte copy
///  - width=1 generates a half-word (16-bit) copy
///  - width=2 generates a word (32-bit) copy
///
#define Dma_Copy_Core(_qual,_self,_dst,_src,_size,_lli,_width) \
    _qual Dma_Define_Descriptor(_self, \
        .src  = (Dma_UIntPtr_t) (_src), \
        .dst  = (Dma_UIntPtr_t) (_dst), \
        .lli  = (Dma_UIntPtr_t) (_lli), \
        .ctrl = UINT32_C(0x0C000000) + (((_width) & 0x3u) << 21u) + (((_width) & 0x3u) << 18u) + (uint32_t) (_size) \
    )

/// \brief Basic byte (8-bit) wise DMA copy operation
///
/// Copies "size" bytes from "src" to "dst". Then links to the next descriptor at "lli".
///
#define Dma_ByteCopy_Core(_qual,_self,_dst,_src,_size,_lli) \
    Dma_Copy_Core(_qual,_self,_dst,_src,_size,_lli,0u)

// Patchable version of Dma_ByteCopy
#define Dma_ByteCopy(_self,_dst,_src,_size,_lli) \
    Dma_ByteCopy_Core(DMACU_READWRITE,_self,_dst,_src,_size,_lli)

// Fixed (non-patchable) version of Dma_ByteCopy
#define Dma_FixedByteCopy(_self,_dst,_src,_size,_lli) \
    Dma_ByteCopy_Core(DMACU_READONLY,_self,_dst,_src,_size,_lli)

/// \brief Basic half-word (16-bit) wise DMA copy operation
///
/// Copies "size" bytes from "src" to "dst". Then links to the next descriptor at "lli".
/// Size give the number of 16-bit half-words to copy
///
#define Dma_HalfWordCopy_Core(_qual,_self,_dst,_src,_size,_lli) \
    Dma_Copy_Core(_qual,_self,_dst,_src,_size,_lli,1u)

// Patchable version of Dma_HalfWordCopy
#define Dma_HalfWordCopy(_self,_dst,_src,_size,_lli) \
    Dma_HalfWordCopy_Core(DMACU_READWRITE,_self,_dst,_src,_size,_lli)

// Fixed (non-patchable) version of DmaHalfWordCopy
#define Dma_FixedHalfWordCopy(_self,_dst,_src,_size,_lli) \
    Dma_HalfWordCopy_Core(DMACU_READONLY,_self,_dst,_src,_size,_lli)

/// \brief Basic word (32-bit) wise DMA copy operation
///
/// Copies "size" bytes from "src" to "dst". Then links to the next descriptor at "lli".
/// Size give the number of 32-bit words to copy
///
#define Dma_WordCopy_Core(_qual,_self,_dst,_src,_size,_lli) \
    Dma_Copy_Core(_qual,_self,_dst,_src,_size,_lli,2u)

// Patchable version of Dma_WordCopy
#define Dma_WordCopy(_self,_dst,_src,_size,_lli) \
    Dma_WordCopy_Core(DMACU_READWRITE,_self,_dst,_src,_size,_lli)

// Fixed (non-patchable) version of DmaHalfWordCopy
#define Dma_FixedWordCopy(_self,_dst,_src,_size,_lli) \
    Dma_WordCopy_Core(DMACU_READONLY,_self,_dst,_src,_size,_lli)

/// \brief Basic byte-wise DMA fill operation.
///
/// Fills a block of "size" bytes at "dst" with the byte found at "src". Then links to the
/// next descriptor at "lli".
///
#define Dma_ByteFill_Core(_qual,_self,_dst,_src,_size,_lli) \
    _qual Dma_Define_Descriptor(_self, \
        .src  = (Dma_UIntPtr_t) (_src), \
        .dst  = (Dma_UIntPtr_t) (_dst), \
        .lli  = (Dma_UIntPtr_t) (_lli), \
        .ctrl = UINT32_C(0x08000000) + (uint32_t) (_size) \
    )

// Fixed (non-patchable) version of Dma_ByteFill
#define Dma_ByteFill(_self,_dst,_src,_size,_lli) \
    Dma_ByteFill_Core(DMACU_READWRITE,_self,_dst,_src,_size,_lli)

// Fixed (non-patchable) version of Dma_ByteFill
#define Dma_FixedByteFill(_self,_dst,_src,_size,_lli) \
    Dma_ByteFill_Core(DMACU_READONLY,_self,_dst,_src,_size,_lli)

//-------------------------------------------------------------------------------------------------
/// \brief Execution state of the DMACU virtual CPU
///
/// \note The DMACU virtual CPU requires the CPU structure to be aligned on an even 256-byte boundary
///   to ensure correct operation of the register file. (Register file accesses patch the lowest
///   byte of DMA source/destination addresses)
///
typedef struct Dmacu_Cpu
{
    /// \brief Register file (256 registers)
    uint8_t RegFile[256u];

    /// \brief Guard zone (catches off-by-one/two/three access for regfile corner-cases)
    uint32_t GuardZone;

    /// \brief Current program counter
    uint32_t PC;

    /// \brief Next program counter
    uint32_t NextPC;

    /// \brief Program base address (initial PC)
    uint32_t ProgramBase;

    /// \brief State tracker for the debug state
    ///
    /// \todo Back-port from assembler implementation (and integrate in the CPU pipeline)
    uint32_t DbgState;

    /// \brief Current instruction word
    union
    {
        /// \brief Byte-wise via (for simpler descriptor construction)
        uint8_t Bytes[4u];

        /// \brief Word value
        uint32_t Value;
    } CurrentOPC;

    /// \brief Operand values
    struct
    {
        /// \brief Current A operand value
        uint32_t A;

        /// \brief Current B operand value
        uint32_t B;

        /// \brief Current Z result value
        uint32_t Z;
    } Operands;

    /// \brief Scratchpad for temporary values
    uint8_t Scratchpad[4u];

    /// \brief Active SBOX (for shared logic pipeline)
    uint32_t ActiveLogicSbox;
} Dmacu_Cpu_t;

/// \brief Gets the virtual CPU's global execution state.
///
extern Dmacu_Cpu_t* Dmacu_GetCpu(void);

/// \brief Gets the DMA descriptor for booting and running the virtual CPU.
///
extern const Dma_Descriptor_t* Dmacu_CpuBootDescriptor(void);

//-------------------------------------------------------------------------------------------------
// Helper functions to interact with the virtual CPU
//

/// \brief Boots the virtual CPU and executes the built-in test program (see utils.c).
///
extern void Dmacu_RunTestProgram(void);

/// \brief Configures a DMACU virtual CPU for executing a test small program.
///
/// \param[out] cpu points to the CPU state object to be configuzed.
///
extern void Dmacu_SetupTestProgram(Dmacu_Cpu_t *cpu);

/// \brief Dumps the current CPU execution state of the virtual CPU to the standard output.
///
/// \param[in] prefix specifies the prefix string to be prepended to each output line.
///
/// \param[in] cpu points to the CPU state object to be dumped.
///
extern void Dmacu_DumpCpuState(const char *prefix, const Dmacu_Cpu_t *cpu);

//-------------------------------------------------------------------------------------------------
// Hardware abstraction layer
//

/// \brief Static configuration of the hardware abstraction layer.
typedef struct Hal_Config
{
    /// \brief Address of the GPIO output pin register
    ///
    /// \deprecated To be removed in favour of the platform_id approach (with platform handling in
    ///   the firmware microcode).
    volatile uint32_t *gpio_pin_reg;

    /// \brief GPIO bitmask for the LED
    ///
    /// \deprecated To be removed in favour of the platform_id approach (with platform handling in
    ///   the firmware microcode).
    uint32_t gpio_led_mask;

    /// \brief HAL platform ID
    ///
    /// We pass this value in r247 to allow the microcode to adapt to the host platform.
    /// Currently the following platform IDs are in use:
    ///
    /// - 0x00 ('\0') Host-based simulation
    /// - 0x41 ('A')  LPCxpresso LPC1769 (or compatible) board.
    /// - 0x51 ('Q')  QEMU simulating a versatilepb board.
    uint8_t platform_id;
} Hal_Config_t;

/// \brief Virtual "host" simulation platform.
#define HAL_PLATFORM_HOST UINT8_C(0x00)

/// \brief LPCxpress LPC1769 (or compatible) board.
#define HAL_PLATFORM_LPCXPRESSO_1769 UINT8_C(0x41)

/// \brief QEMU simulating a versatilepb board.
#define HAL_PLATFORM_QEMU UINT8_C(0x51)

/// \brief Static HAL configuration (provided by the platform layer)
extern const Hal_Config_t gHalConfig;

/// \brief Initializes the hardware abstraction layer.
///
/// \note This function must be provided by the platform specific port to initalize platform specific
///   hardware features for the DMACU environment.
///
extern void Hal_Init(void);

/// \brief Executes a DMA transfer (via the PL080 DMA controller).
///
/// \param[in] desc is the first DMA descriptor in the transfer chain.
extern void Hal_DmaTransfer(const Dma_Descriptor_t *desc);

#endif // DMACU_H_
