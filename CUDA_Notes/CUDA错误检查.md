# 运行时API错误代码
+ 运行时API大多支持返回错误代码，返回值类型：`cudaError_t`
+ 运行时API成功执行，返回值为`cudaSuccess`
+ 运行时API返回的执行状态值是枚举变量

> 枚举是 C 语言中的一种基本数据类型，用于定义一组具有离散值的常量，它可以让数据更简洁，更易读。

`cudaSuccess = 0`
# 错误检查函数
+ 输入错误代码(`cudaError_t`)，获取错误代码对应名称：`cudaGetErrorName`，返回char类型的指针（char*）
+ 同上，获取错误代码描述信息：`cudaGetErrorSrting`，返回值同上
主机设备都可以执行

如何使用：
1. 在调用CUDA运行时API时，调用ErrorCheck函数进行包装
2. 参数filename一般使用`__FILE__`，参数linenumber一般使用`__LINE__`（类似常量）
3. 错误函数返回运行时API调用的错误代码
```cpp
cudaError_t ErrorCheck(cudaError_t error_code, const char* filename, int lineNumber){
		if(error_code != cudaSuccess){
		printf("code=%d,name=%s,descb=%s,file=%s,line=%d\r\n",cudaGetErrorName(error_code), cudaGetErrorString(error_code), filename, lineNumber)
		return error_code;
	}
	return error_code;
}
```
# 检查核函数
+ 错误检测函数的问题：不能捕捉调用核函数的相关错误
+ 利用错误检查函数捕捉调用核函数可能发生错误的方法：`ErrorCheck(cudaGetLastError(), __FILE__, __LINE__)`, 与`ErrorCheck(cudaDeviceSynchronize(), __FILE__, __LINE__)`