#include<stdio.h>
#include<stdlib.h>
#include<graphics.h>
#include<cuda.h>
#include<math.h>
#include <curand.h>
#define max 70
const int noofthreads = 48;
const int noofblocks= 64;
__global__ void matrix(int *old, int *x,int *y){
	__shared__ count= 100;
	__shared__ int new[noofthreads];
	
	int tid= threadIdx.x;
	
	if(tid)
		new[threadIdx.x] = old[threadIdx.x + 1][blockIdx.x] % 5;
	
	else{
		
		
		new[threadIdx.x] =  % 5;
		// assume have already set up curand and generated state for each thread...
		// assume ranges vary by thread index
		
	}	
	__syncthreads();
	
	x[threadIdx.x][blockIdx.x] = threadIdx.x * 10;
	y[threadIdx.x][blockIdx.x] = blockIdx.x * 10;
	
	old[threadIdx.x][blockIdx.x] = new[threadIdx.x];
	
}

int main()
{
    int gd=DETECT, gm;
	//int *xii, *yii;
    int xi[noofthreads][noofblocks], yi[noofthreads][noofblocks];
    int r[noofthreads][noofblocks] ; // r for position of 1 or 0.
    //int cnt=0, x, y;    //cnt will help for randomly filling the first cycle of whole screen
	
    initgraph(&gd, &gm, NULL);
    
    int *dev_a, *dev_x, dev_y;
    
    cudaMalloc((void**)&dev_a,  noofthreads * noofblocks * sizeof(int));
    cudaMalloc((void**)&dev_x,  noofthreads * noofblocks * sizeof(int));
    cudaMalloc((void**)&dev_y,  noofthreads * noofblocks * sizeof(int));
    
    cudaMemcpy(dev_a, r, noofthreads * noofblocks * sizeof(int), cudaMemcpyHostToDevice );
	
	matrix<<<noofblocks,noofthreads>>>(dev_a, xi, yi);
	
	cudaMemcpy(r, dev_a, noofthreads * noofblocks * sizeof(int), cudaMemcpyDeviceToHost );
	cudaMemcpy(xi, dev_x, noofthreads * noofblocks * sizeof(int), cudaMemcpyDeviceToHost );
	cudaMemcpy(yi, dev_y, noofthreads * noofblocks * sizeof(int), cudaMemcpyDeviceToHost );
    
    
    
do{
	
	cudaMemcpy(dev_a, r, noofthreads * noofblocks * sizeof(int), cudaMemcpyHostToDevice );
	
	matrix<<<noofblocks,noofthreads>>>(dev_a, xi, yi);
	
	cudaMemcpy(r, dev_a, noofthreads * noofblocks * sizeof(int), cudaMemcpyDeviceToHost );
	
     for(int i=0; i<noofblocks; i++){
          for(int j=0; j<noofthreads; j+=2){    //extra space needed to look neat, so j is double incremented
                        
               // x= i*10 ;       //as the window is divided into 64*48, we multiply by 10 for position
               // y= j*10 ;
                                
                        /// This is for making that position blank and ready for next entry
                setcolor(0);    // make it disapper
                                            
                if(r[i][j]==0){ 
                       line(xi[i][j] + 4, yi[i][j]  + 6, xi[i][j]  + 5, yi[i][j]  + 5);//1's head
                       line (xi[i][j]  + 5, yi[i][j]  + 5, xi[i][j]  + 5, yi[i][j]  + 15);// 1's spine
                       line(xi[i][j]  + 4, yi[i][j]  + 15, xi[i][j]  + 6, yi[i][j]  + 15);// 1's base
                }
                else if(r[i][j]==1)
                       ellipse(xi[i][j]  + 5, yi[i][j]  + 10, 0, 360, 2 , 5); //draw 0
                 
 //delay(10);
                setcolor(2);
                               
                if(r[i][j]==0){
                      line(xi[i][j]  + 4, yi[i][j]  + 6, xi[i][j]  + 5, yi[i][j]  + 5);
                      line (xi[i][j]  + 5, yi[i][j]  + 5, xi[i][j]  + 5, yi[i][j]  + 15);
                      line(xi[i][j]  + 4, yi[i][j]  + 15, xi[i][j]  + 6, yi[i][j]  + 15);
                }
                else if(r[i][j]==1)
                      ellipse(xi[i][j]  + 5, yi[i][j]  + 10, 0, 360, 2 , 5);
                    }
                }
}while(1);		//for infinite loop
           //delay(9999);
    closegraph();
}
