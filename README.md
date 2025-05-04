## miniSQL
### 简介
该仓库源自于编译原理作业，目标是通过词法分析、语法分析和语法制导翻译制作一个小型的SQL解释器。词法规则与语法规则仅根据`test_data.txt`文件中的测试数据编写，不能用于实际SQL生产环境。项目目的为加深课本相关知识理解，并通过实践了解实际编译器开发方法与流程。
### 问题记录
#### 文法规则出现移位/归约冲突问题
文法规则编写过程中关于`select`等语句中的`where`条件语句出现过`shift/reduce conflict`问题，原因是在`conditions`文法规则中出现  
```
conditions  :   conditions KW_AND conditions
            |   conditions KW_OR conditions
            ;
```
通过询问**Deepseek**工具进行修改，得到**src/myParser.y**文件中标记的代码块，并受到**添加非终结符**的启发，自己对文法进行了一定的修改，亦在文件中有标记。此外，还询问了**Deepseek**两种文法的区别，并记录在了两个代码块下方。
### 测试

#### 工具与环境
Linux平台 flex bison gcc
#### 命令
make run  
#### 特！别！说！明！
**请严格按照`test_data.txt`文件中的SQL语法格式构造测试用例**  
目前仅实现词法文法的识别，后期会根据实际实验情况继续完善