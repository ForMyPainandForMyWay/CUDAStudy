# include<stdio.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <iostream>
#include<Windows.h>


__global__ void addfromGPU(float *A, float *B, float *C, const int n) {
	const int bid = blockIdx.x;
	const int tid = threadIdx.x;
	const int id = tid + bid * blockDim.x;
	//if (id >= 5) return;
	C[id] = A[id] + B[id];
	return;
}

void setGPU() {
	int iDevice = 0;
	cudaSetDevice(iDevice);
}

void initiaData(float *addr, int element) {
	for (int i = 0; i < element; i ++) {
		addr[i] = (float)(rand() & 0xFFF) / 10.f;
	}
	return;
}

int main(){
	//设置化设备
	setGPU();

	//分配主机内存和设备内存，并初始化
	int iElement = 5120;  //set the size of element
	size_t bytesize = iElement * sizeof(float);  //设置内存空间

	//设置主机内存空间
	float *fpHost_A, *fpHost_B, *fpHost_C;
	fpHost_A = (float*)malloc(bytesize);
	fpHost_B = (float*)malloc(bytesize);
	fpHost_C = (float*)malloc(bytesize);
	//初始化主机内存空间
	memset(fpHost_A, 0, bytesize);
	memset(fpHost_B, 0, bytesize);
	memset(fpHost_C, 0, bytesize);

	//设置设备内存空间
	float *fpDevice_A, *fpDevice_B, *fpDevice_C;
	cudaMalloc((float**)&fpDevice_A,bytesize);
	cudaMalloc((float**)&fpDevice_B, bytesize);
	cudaMalloc((float**)&fpDevice_C, bytesize);
	//初始化设备内存空间
	cudaMemset(fpDevice_A, 0, bytesize);
	cudaMemset(fpDevice_B, 0, bytesize);
	cudaMemset(fpDevice_C, 0, bytesize);

	//初始化主机内存数据
	srand(666);
	initiaData(fpHost_A, iElement);
	initiaData(fpHost_B, iElement);

	//从主机复制到设备
	cudaMemcpy(fpDevice_A, fpHost_A, bytesize, cudaMemcpyHostToDevice);
	cudaMemcpy(fpDevice_B, fpHost_B, bytesize, cudaMemcpyHostToDevice);

	//调用核函数在设备中进行计算
	dim3 block(512);
	dim3 grid(iElement / 512);

	//count time
	double start = clock();
	addfromGPU <<<grid, block>>> (fpDevice_A, fpDevice_B, fpDevice_C, iElement);
	double end = clock();
	printf("%lf\n\n", end-start);

	//拷贝回去并展示
	cudaMemcpy(fpHost_C, fpDevice_C, bytesize, cudaMemcpyDeviceToHost);;
	for (int i = 0; i < 10; i++)
	{
		printf("%lf, %lf, %lf\n", fpHost_A[i], fpHost_B[i], fpHost_C[i]);
	}

	free(fpHost_A);
	free(fpHost_B);
	free(fpHost_C);
	cudaFree(fpDevice_A);
	cudaFree(fpDevice_B);
	cudaFree(fpDevice_C);
	return 0;
}