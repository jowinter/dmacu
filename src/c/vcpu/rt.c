/**
 * PoC virtual CPU implementation for the ARM PL080 DMA Controller.
 *
 * Copyright (c) 2019-2022 Johannes Winter <jrandom@speed.at>
 *
 * This file is licensed under the MIT License. See LICENSE in the root directory
 * of the project for the license text.
 */

/**
 * @file rt.c
 * @brief Runtime-Environment (and startup code)
 */
#include "dmacu.h"

#include <stdlib.h>

//-------------------------------------------------------------------------------------------------
int main(void)
{
	// HAL-level initialization
	Hal_Init();

	// And run our test-program
	Dmacu_RunTestProgram();

	return EXIT_SUCCESS;
}
