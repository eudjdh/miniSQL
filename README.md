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
- [ ] drop数据库
- [ ] drop表格
- [x] show数据库
- [ ] show表格
- [ ] insert数据
- [ ] update数据
- [ ] delete数据
- [ ] select数据
- [x] exit数据库或miniSQL
### 问题记录
#### ✅文法规则出现移位/归约冲突问题  
文法规则编写过程中关于`select`等语句中的`where`条件语句出现过`shift/reduce conflict`问题，原因是在`conditions`文法规则中出现  
```
conditions  :   conditions KW_AND conditions
            |   conditions KW_OR conditions
            ;
```
通过询问**Deepseek**工具进行修改，得到**src/myParser.y**文件中标记的代码块，并受到**添加非终结符**的启发，自己对文法进行了一定的修改，亦在文件中有标记。此外，还询问了**Deepseek**两种文法的区别，并记录在了两个代码块下方。
#### ✅具体值无法传给终结符
需要在.l文件中强制赋值给终结符，并在.y文件中进行属性绑定
### 测试
#### 工具与环境
Linux平台 Flex Bison gcc Makefile
#### 命令
make run  
#### 特！别！说！明！
**请严格按照`test_data.txt`文件中的SQL语法格式构造测试用例**  
exit用法：当你处于某数据库下，键入exit命令退出至database主目录；当你处于database主目录，键入exit命令退出miniSQL