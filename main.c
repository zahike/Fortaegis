#include "xstatus.h"
#include "xil_types.h"
#include "xparameters.h"


#ifdef XPAR_PS7_RAM_0_S_AXI_BASEADDR
#define DDR_BASE_ADDR		XPAR_PS7_RAM_0_S_AXI_BASEADDR
#define MEM_BASE_ADDR		(DDR_BASE_ADDR + 0x1000000)
#else
#define MEM_BASE_ADDR		XPAR_BRAM_0_BASEADDR
#endif

#define DATA_BUFF	(MEM_BASE_ADDR + 0x00000000)

u32 *APB = XPAR_APB_M_0_BASEADDR;
u32 *DMA = XPAR_AXIDMA_0_BASEADDR;

int main (void)
{
	u32 data;

	data   = DMA[0x30/4];
	DMA[0x30/4] = 0x04;
	DMA[0x48/4] = DATA_BUFF;
	data   = DMA[0x30/4];
	DMA[0x30/4] = data | 0x00000001;
	DMA[0x58/4] = 0x200;

	APB[0] = 0x0;

data = 0;
	while (data == 0){
		data   = DMA[0x34/4];
	}

	data = APB[1];
	data = APB[2];
	data = APB[3];

	return XST_SUCCESS;
}
