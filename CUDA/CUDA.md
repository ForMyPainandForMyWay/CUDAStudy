cuda程序不能使用cout输出？
# 核函数
GPU可以看作是CPU的一个协处理器，其运行仍然受到CPU的控制
主机对GPU设备的调用是通过调用核函数进行的
+ 和函数在GPU上进行**并行执行**
+ 限定词`__global__`修饰
+ 返回值必须是`void`
+ 核函数只能访问GPU内存（无法直接访问CPU内存内容），需要使用运行时的特定API接口交互
+ 核函数不能使用变长参数，书写时就要明确参数的个数
+ 不能使用静态变量
+ 不能使用函数指针
+ 核函数具有异步性，CPU只能启动核函数的运行，无法控制，CPU主机不会等待核函数执行完毕，要显示地调用同步函数，同步CPU和GPU的工作进程
+ 核函数不支持C++的iostream类（无法使用cout输出）
形式：
```cpp
__global__ void kernel(void) {
	printf("hello world\n");
}
```

CUDA程序编写流程
```cpp
int main(void){
	//主机代码
	//核函数调用
	//主机代码，一般将GPU处理过的数据回传给GPU，还会进行内存释放的工作
	return 0;
}
```
核函数的调用：
在括号前使用`<<<grid_size, block_size>>>`指定工作的GPU线程数，其中grid_size表示grid中线程块的数量，block_size表示每个线程块中线程的数量
注：如果使用printf测试，发现最后输出的字符串行数等于`grid_size*block_size`

核函数同步：
`cudaDeviceSynchronize();`作用是等待调用GPU执行完毕
# 线程模型
线程分块是逻辑上的划分，物理上线程不分块
配置线程：`<<<grid_size, block_size>>>`
+ 每个线程的唯一表示由这两个元素确定，两者保存在==内建变量==中：
1. gridDim.x = grid_size（指示grid的维度）
2. blockDim.x = block_size（指示block的维度）
最大允许的线程块大小：1024
最大允许网格大小：$2^{23}-1$(针对一维)
设计总的线程数时，至少要等与计算核心数，才能发挥GPU的计算能力，实际使用中，总的线程数大于计算核心数时才能更充分利用

+ 线程索引保存成内建变量：
1. blockldx.x   指定一个线程在一个网格中的线程块索引值，范围为0~gridDim.x-1（指定所在block属于那个grid，即block的index）
2. treadld.x   指定一个线程在一个线程块中的线程索引值，范围为0~blockDim.x-1（指定所在线程属于哪个block）
**例子：**
![[Pasted image 20240301120647.png]]
```cpp
__global__ void kernel() {
	const int bid = blockIdx.x;
	const int tid = threadIdx.x;
	const int bdim = blockDim.x;
	int thread_index = tid + bid * bdim;
	printf("hello world form %d thread and from %d blocks\n", thread_index, bid);
}

>>
hello world form 0 thread and from 0 blocks
hello world form 1 thread and from 0 blocks
hello world form 2 thread and from 1 blocks
hello world form 3 thread and from 1 blocks
```
**推广到多线程**
1. cuda可以组织三维的网格和线程块
2. blockIdx和threadIdx是类型为`uint3`的变量，==该类型是一个结构体==，具有x，y，z三个成员（三个成员都为无符号类型的成员构成），==各个成员范围类似，表示各自维度的范围==
3. 内建变量只在核函数中有效，无需定义
4. 当没有指定`gridDim`和`blockDim`的维度时，默认为一，比如`<<<2,4>>>`就只指定了x上的数量，其他维度是一
+ 定义多维网格和线程块（C++构造函数语法）：
	`dim3 grid_size(Gx, Gy, Gz);dim3 block_size(Bx, By, Bz);`然后将其传入`<<<>>>`中
	==注意线程的索引与矩阵是相反的==
## 线程全局索引计算方式
**线程全局索引**
<font color='red'>注意：GPU中多维的网格和区块的行列索引是反的，x表示列，y表示行</font>（x, y, z）

**不同组合方式列举**
![[Pasted image 20240303175908.png]]