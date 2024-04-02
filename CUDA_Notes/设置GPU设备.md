# 获取GPU设备数量
既可以在主机调用，也可以在设备上调用，返回值为错误代码（类型为cudaError_t），以表明运行状态，若值为cudaSuccess，表明调用成功
```cpp
int main(){
	int iDeviceCount = 0;
	//该函数将GPU设备数量赋值给int变量，使用地址传递
	cudaGetDeviceCount(&iDeviceCount);
	return 0;
}
```
# 设置GPU执行时的设备
利用`int`设置运行设备，__只能在主机中进行调用__
```cpp
int main(){
	int iDevice = 0;
	cudaSetDevice(iDevice);
	return 0;
}
```