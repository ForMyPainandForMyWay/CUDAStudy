![[Pasted image 20240303181120.png]]
# 设置GPU设备
1. 获取GPU设备数量
接受int类型的数据的引用，在内部修改为数量的值
若返回`cudaError`的数据，值为`cudaSuccess`说明调用成功
```cpp
int iDeviceCount = 0;
cudaGetDeviceCount(&iDeviceCount);
```
2. 设置GPU执行时使用的设备
	设置设备，传入地址
	若返回`cudaError`类型的数据，值为`cudaSuccess`说明调用成功
```cpp
int iDev = 0;
cudaSetDevice(iDev);
```
# 内存管理
通过内存分配，数据传递，内存初始化，内存释放进行内存管理
![[Pasted image 20240303182625.png]]
从上到下分别是：内存分配，数据传递，内存初始化，内存释放。
其内存管理函数在主机与设备之间都可以调用