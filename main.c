#include "xstatus.h"
#include "xil_types.h"
#include "xparameters.h"
#include "sleep.h"


#ifdef XPAR_PS7_RAM_0_S_AXI_BASEADDR
#define DDR_BASE_ADDR		XPAR_PS7_RAM_0_S_AXI_BASEADDR
#define MEM_BASE_ADDR		(DDR_BASE_ADDR + 0x1000000)
#else
#define MEM_BASE_ADDR		XPAR_BRAM_0_BASEADDR
#endif

#define DATA_BUFF	(MEM_BASE_ADDR + 0x00000000)
#define RESULTS	    (MEM_BASE_ADDR + 0x00028000)

u32 *APB = XPAR_APB_M_0_BASEADDR;
u32 *DMA = XPAR_AXIDMA_0_BASEADDR;

int main (void)
{
	u32 *FrameData = DATA_BUFF;
	u32 data;
	u32 data1;
	u32 data2;
	u32 data3;
	u32 Data1Value,Data1Count;
	u32 Data2Value,Data2Count;
	u32 Data3Value,Data3Count;
	u32 *Results = RESULTS;

	data   = DMA[0x30/4];
	DMA[0x30/4] = 0x04;
	DMA[0x48/4] = DATA_BUFF;
	data   = DMA[0x30/4];
	DMA[0x30/4] = data | 0x00000001;
	DMA[0x58/4] = 0x20000;

	APB[0] = 0x1;
	sleep(3);
	APB[0] = 0x0;


data = 0;
	while (data == 0){
		data   = DMA[0x34/4];
	}

	Xil_DCacheInvalidateRange((u32)FrameData, 0x20000);

	data1 = APB[1];
	Data1Value = (data1 &0xFFFF0000) >> 16;
	Data1Count = data1 &0x0000FFFF;
	data2 = APB[2];
	Data2Value = (data2 &0xFFFF0000) >> 16;
	Data2Count = data2 &0x0000FFFF;
	data3 = APB[3];
	Data3Value = (data3 &0xFFFF0000) >> 16;
	Data3Count = data3 &0x0000FFFF;
	int CounData1 = 0;
	int CounData2 = 0;
	int CounData3 = 0;
	int Count = 0;
	u32 Data1Arry[Data1Count];
	u32 Data2Arry[Data2Count];
	u32 Data3Arry[Data3Count];
for (int i=0;i<0x8000;i++)
{
	if (FrameData[i] == Data1Value) {
		Data1Arry[CounData1] = 4*i;
		CounData1++;
	}
	if (FrameData[i] == Data2Value) {
		Data2Arry[CounData2] = 4*i;
		CounData2++;
	}
	if (FrameData[i] == Data3Value) {
		Data3Arry[CounData3] = 4*i;
		CounData3++;
	}
}

	return XST_SUCCESS;
}
