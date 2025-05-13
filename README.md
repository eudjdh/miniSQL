## miniSQL
### 简介
该仓库源自于编译原理作业，目标是通过词法分析、语法分析和语法制导翻译制作一个小型的SQL解释器。词法规则与语法规则仅根据`test_data.txt`文件中的测试数据编写，不能用于实际SQL生产环境。项目目的为加深课本相关知识理解，并通过实践了解实际编译器开发方法与流程。
### 物理结构
该解释器采用一种类似文件系统的、简单的物理结构设计数据库，具体形式如下
```
database/
    ├── sys.bat                 # 每行存储一个数据库名
    ├── example_db1/
    │       ├── sys.bat         # 每行存储一个表的元数据
    │       ├── example_tb1.txt # 每行存储一条基本数据
    │       └── example_tb2.txt
    └── example_db2/
            ├── sys.bat
            └── example_tb3.txt
```
其中每个数据库的sys.bat文件中的每一行存储形如`example_tb1 1 example_col1 int`和`example_tb1 2 example_col2 char 20`的元数据，即`表名 自增的元数据序号 列名 数据类型 长度(仅char类型有)`
### 工作进度
- [x] 词法分析
- [x] 语法分析
- [x] create数据库
- [x] use数据库
- [x] create表格
- [x] drop数据库
- [x] drop表格
- [x] show数据库
- [x] show表格
- [x] insert数据
- [x] update数据
- [x] delete数据
- [x] select单表查询
- [ ] select多表连接查询
- [x] exit数据库或miniSQL
### 问题记录
#### ✅文法规则出现移位/归约冲突问题(大乌龙🤣🤣🤣🤣🤣)
文法规则编写过程中关于`select`等语句中的`where`条件语句出现过`shift/reduce conflict`问题，原因是在`conditions`文法规则中出现  
```
conditions  :   conditions KW_AND conditions
            |   conditions KW_OR conditions
            ;
```
通过询问`deepseek`得知可以通过声明优先级的方式规避这种冲突，于是声明
```
%left OR
%left AND
```
但是修改后依然有冲突警告，挣扎很久后（甚至大幅修改了文法规则，变得复杂难读，详见我的commit记录），最终得知犯下愚蠢错误，`OR`和`AND`token从未出现过，而是`KW_OR`和`KW_AND`🤣🤣🤣🤣🤣  
最终改为
```
%left KW_OR
%left KW_AND
```
最终不显示存在冲突
#### ✅具体值无法传给终结符
需要在.l文件中强制赋值给终结符，并在.y文件中进行属性绑定
#### ✅C语言中无法直接删除文件行
需要逐行扫描原文件并复制到新文件中，其中跳过需要删除的行。原因是C语言读取文件按照字节流的方式读取，若删除特定行，需将后面部分向前移动若干字节，危险且麻烦
### 测试
#### 工具与环境
Linux平台 Flex Bison gcc Makefile
#### 命令
make run  
#### 约定
- exit用法：当你处于某数据库下，键入exit命令退出至database主目录；当你处于database主目录，键入exit命令退出miniSQL  
- 若插入时数据不全，系统会在空缺处记录'*'，表示数据为空
#### 特！别！说！明！
**请严格按照`test_data.txt`文件中的SQL语法格式构造测试用例**  