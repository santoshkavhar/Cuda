#include<stdio.h>
#include<cuda.h>
#define sum_numbers(x) (x*(x+1)/2)
//N from 0 to 7
#define N 13000	
const int NoOfThreads = 128;
const int NoOfBlocks = (N+127)/128;

__global__ void means(float *a){
    // a[0] = 0; a[1] = 1;
    int id = blockIdx.x * blockDim.x + threadIdx.x;
    if(id < N)
        a[id] = id;
	else
		a[id] = 0;
    __syncthreads();
    // no. of threads in a block
    
    int i= blockDim.x/2;
    while(i != 0){
        if(threadIdx.x < i)
            a[id] += a[id + i];
        __syncthreads();
        i /= 2;
    }
    __syncthreads();
	// 0th thread of each block except 0th block add their sum to a[0] atomically
    //threadIdx.x =0 && id != 0
    if(!threadIdx.x && id)
    	atomicAdd(&a[0], a[id] );
   //cudaDeviceSynchronize();
   
   	//only 0th thread of 0th block computes mean
   	// it doesn't work!!!
   	// send directly the total sum
}


int main(){
    // copy dev_a from device to host
    // c wil hold the mean
    // dev_a is created on the device and holds the numbers
    float c; /* *a,*/
    float *dev_a;
	//Lock lock;
    //allocate memory on CPU side
    //a = (float*)malloc(N*sizeof(float));

    //allocate memory on GPU side
    cudaMalloc( (void**)&dev_a, N*sizeof(float));
	
    means<<<NoOfBlocks,NoOfThreads>>>(dev_a);
    // copy mean to c 
    cudaMemcpy(&c, dev_a, sizeof(float), cudaMemcpyDeviceToHost);
    // computing mean on CPU than GPU because of error caused
    // GPU doesn't have block synchronisation so other blocks sum isn't written to 0th block
    c= c/N;
    printf("Does GPU value %.6g = %.6g\n", c, (sum_numbers( (float)(N - 1) )/N) );
    
    cudaFree(dev_a);
    
    return 0;
}
