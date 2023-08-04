#include<stdio.h>
#include<cuda.h>
//N from 0 to 7
//#define N 
const int N = 128;
__global__ void bubble(float* a) {
	// a[0] = 0; a[1] = 33; a[2] = 66... a[];
	int tid = blockIdx.x * blockDim.x + threadIdx.x;
	if (tid < N)
		a[tid] = N- threadIdx.x;
	else
		a[tid] = 0;

	__syncthreads();

	// no. of threads in a block
	//int i= blockDim.x/ 2;
	int temp;
	for (int i = 0; i < N; i++) {
		// if odd iteration and odd thread
		// if iteration is even and even thread
		if ((i % 2 && tid % 2) || ((i + 1) % 2 && (tid + 1) % 2)) {
			//for 0th element, be careful
			if (tid && ( a[tid - 1] > a[tid]) ) {
				temp = a[tid];
				a[tid] = a[tid - 1];
				a[tid - 1] = temp;
			}
		}
		__syncthreads();
	}
}

int main() {
	// copy dev_a from device to host
	// c wil hold the mean
	// dev_a is created on the device and holds the numbers
	float* a;
	float* dev_a;

	//allocate memory on CPU side
	a = (float*)malloc(N * sizeof(float));

	//allocate memory on GPU side
	cudaMalloc((void**)&dev_a, N * sizeof(float));

	bubble<<<(N + 127)/128, 128 >>> (dev_a);
	// copy mean to c 
	cudaMemcpy(a, dev_a, N * sizeof(float), cudaMemcpyDeviceToHost);


	for (int i = 0; i < N; i++)
		printf("\n%f", a[i]);
	free(a);
	cudaFree(dev_a);
}
