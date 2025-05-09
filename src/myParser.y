%{
    #include "db.h"
    extern int yylex(void);
    extern void yyerror(const char *s);
%}

%union{
    char *str_val;                              // 字符串值，数字和标识符都以字符串存储操作，仅有设计比较时才会转换为数字
    struct create_struct *create_var;           // create语句的值
    struct create_table_entries *entries_var;   // create table的列链表
    struct use_struct *use_var;                 // use语句的值
    struct show_struct *show_var;               // show语句的值
    struct drop_struct *drop_var;               // drop语句的值
    struct insert_value *value_var;             // insert语句中的values
    struct insert_column *column_var;           // insert语句中的columns
    struct insert_struct *insert_var;           // insert语句的值
}

%token <str_val> IDENTIFIER NUMBER 

%type <create_var> create_sql
%type <entries_var> entries entry
%type <use_var> use_sql
%type <show_var> show_sql
%type <drop_var> drop_sql
%type <value_var> values value
%type <column_var> columns
%type <insert_var> insert_sql

%token NOT_EQUAL '=' '<' '>' ';' ',' '(' ')' GREATER_OR_EQUAL LESS_OR_EQUAL
%token SINGLE_QUOTE STAR KW_CHAR KW_INT KW_CREATE KW_TABLE KW_DATABASE KW_DATABASES
%token KW_SHOW KW_TABLES KW_USE KW_DROP KW_INSERT KW_INTO KW_VALUES KW_SELECT
%token KW_FROM KW_WHERE KW_AND KW_OR KW_DELETE KW_UPDATE KW_SET EXIT UNKNOWN
%left  OR
%left  AND
%nonassoc '=' '>' '<' NOT_EQUAL GREATER_OR_EQUAL LESS_OR_EQUAL
%nonassoc '(' ')'

%%

statements  :   statement                                                                       {printf("%s>", pwd);}
            |   statements statement                                                            {printf("%s>", pwd);}
            ;

statement   :   create_sql
                {
                    int result;
                    if($1->object_type == DATABASE){
                        result = create_database($1);
                        if(result == 1)
                            printf("创建数据库%s成功\n", $1->name);
                        else if(result == 2)
                            printf("数据库%s已存在\n", $1->name);
                        else if(result == 3)
                            printf("请退回到/home/tom/Documents/compiling/miniSQL/database目录创建数据库\n");
                        else
                            printf("创建数据库失败\n");
                    }
                    else if($1->object_type == TABLE){
                        result = create_table($1);
                        if(result == 1)
                            printf("创建表%s成功\n", $1->name);
                        else if(result == 2)
                            printf("表%s已存在\n", $1->name);
                        else if(result == 3)
                            printf("请进入数据库后创建表\n");
                        else
                            printf("创建表失败\n");
                    }
                    free_create_struct($1);
                }
            |   show_sql
                {
                    int result;
                    if($1->object_type == DATABASE){
                        result = show_database($1);
                        if(result == 1)
                            printf("数据库全部打印完毕\n");
                        else if(result == 2)
                            printf("请退回到/home/tom/Documents/compiling/miniSQL/database目录查询数据库\n");
                        else
                            printf("查询数据库失败\n");
                    }
                    else if($1->object_type == TABLE){
                        result = show_table($1);
                        if(result == 1)
                            printf("表全部打印完毕\n");
                        else if(result == 2)
                            printf("请进入数据库后查询表\n");
                        else
                            printf("查询表失败\n");
                    }
                    free_show_struct($1);
                }
            |   use_sql
                {
                    int result;
                    result = use_database($1);
                    if(result == 1)
                        printf("已切换到数据库%s\n", $1->db_name);
                    else if(result == 2)
                        printf("数据库%s不存在\n", $1->db_name);
                    else
                        printf("切换数据库失败\n");
                    free_use_struct($1);
                }
            |   drop_sql
                {
                    int result;
                    if($1->object_type == DATABASE){
                        result = drop_database($1);
                        if(result == 1)
                            printf("删除数据库%s成功\n", $1->name);
                        else if(result == 2)
                            printf("数据库%s不存在\n", $1->name);
                        else if(result == 3)
                            printf("请退回至/home/tom/Documents/compiling/miniSQL/database目录删除数据库\n");
                        else
                            printf("删除数据库失败\n");
                    }
                    else if($1->object_type == TABLE){
                        result = drop_table($1);
                        if(result == 1)
                            printf("删除表%s成功\n", $1->name);
                        else if(result == 2)
                            printf("表%s不存在\n", $1->name);
                        else if(result == 3)
                            printf("请进入数据库删除表\n");
                        else
                            printf("删除表失败\n");
                    }
                    free_drop_struct($1);
                }
            |   insert_sql
                {
                    int result;
                    result = insert_data($1);
                    if(result == 1)
                        printf("插入数据成功\n");
                    else if(result == 2)
                        printf("表%s不存在\n", $1->table_name);
                    else if(result == 3)
                        printf("请进入数据库进行插入操作\n");
                    else if(result == 4)
                        printf("数据类型不匹配\n");
                    else if(result == 5)
                        printf("CHAR类型数据超出最大长度\n");
                    else if(result == 6)
                        printf("列不存在\n");
                    else
                        printf("插入数据失败\n");
                    free_insert_struct($1);
                }
            |   select_sql
            |   delete_sql
            |   update_sql
            |   EXIT
                {
                    if(strcmp(pwd, "database") == 0){
                        printf("退出miniSQL\n");
                        return 0;
                    }
                    else{
                        strncpy(pwd, "database", 9);
                    }
                }
            ;

create_sql  :   KW_CREATE KW_DATABASE IDENTIFIER ';'
                {
                    $$ = (struct create_struct*)malloc(sizeof(struct create_struct));
                    $$->object_type = DATABASE;
                    $$->name = strdup($3);
                    $$->entries_list = NULL;
                }
            |   KW_CREATE KW_TABLE IDENTIFIER '(' entries ')' ';'                               
                {
                    $$ = (struct create_struct*)malloc(sizeof(struct create_struct));
                    $$->object_type = TABLE;
                    $$->name = strdup($3);
                    $$->entries_list = $5;
                }
            ; 

entries     :   entry
                {
                    $$ = $1;
                }
            |   entries ',' entry
                {
                    if(!$1)
                        $$ = $3;
                    else{
                        struct create_table_entries *last = $1;
                        while(last->next_entry != NULL)
                            last = last->next_entry;
                        last->next_entry = $3;
                        $$ = $1;
                    }
                }
            ;

entry       :   IDENTIFIER KW_CHAR '(' NUMBER ')'
                {
                    $$ = (struct create_table_entries*)malloc(sizeof(struct create_table_entries));
                    $$->entry_name = strdup($1);
                    $$->entry_type = CHAR;
                    $$->length = atoi($4);
                    $$->next_entry = NULL;
                }
            |   IDENTIFIER KW_INT
                {
                    $$ = (struct create_table_entries*)malloc(sizeof(struct create_table_entries));
                    $$->entry_name = strdup($1);
                    $$->entry_type = INT;
                    $$->length = 0;
                    $$->next_entry = NULL;
                }
            ;

show_sql    :   KW_SHOW KW_DATABASES ';'
                {
                    $$ = (struct show_struct*)malloc(sizeof(struct show_struct));
                    $$->object_type = DATABASE;
                }
            |   KW_SHOW KW_TABLES ';'
                {
                    $$ = (struct show_struct*)malloc(sizeof(struct show_struct));
                    $$->object_type = TABLE;
                }
            ;

use_sql     :   KW_USE KW_DATABASE IDENTIFIER ';'
                {
                    $$ = (struct use_struct*)malloc(sizeof(struct use_struct));
                    $$->db_name = strdup($3);
                }

drop_sql    :   KW_DROP KW_DATABASE IDENTIFIER ';'
                {
                    $$ = (struct drop_struct*)malloc(sizeof(struct drop_struct));
                    $$->name = strdup($3);
                    $$->object_type = DATABASE;
                }
            |   KW_DROP KW_TABLE IDENTIFIER ';'
                {
                    $$ = (struct drop_struct*)malloc(sizeof(struct drop_struct));
                    $$->name = strdup($3);
                    $$->object_type = TABLE;
                }
            ;

insert_sql  :   KW_INSERT KW_INTO IDENTIFIER '(' columns ')' KW_VALUES '(' values ')' ';'
                {
                    $$ = (struct insert_struct*)malloc(sizeof(struct insert_struct));
                    $$->table_name = strdup($3);
                    $$->columns = $5;
                    $$->values = $9;
                }
            |   KW_INSERT KW_INTO IDENTIFIER KW_VALUES '(' values ')' ';'
                {
                    $$ = (struct insert_struct*)malloc(sizeof(struct insert_struct));
                    $$->table_name = strdup($3);
                    $$->columns = NULL;
                    $$->values = $6;
                }
            ;

columns     :   IDENTIFIER
                {
                    $$ = (struct insert_column*)malloc(sizeof(struct insert_column));
                    $$->name = strdup($1);
                    $$->next_column = NULL;
                }
            |   columns ',' IDENTIFIER
                {
                    struct insert_column *temp = (struct insert_column*)malloc(sizeof(struct insert_column));
                    temp->name = strdup($3);
                    temp->next_column = NULL;
                    if(!$$)
                        $$ = temp;
                    else{
                        struct insert_column *last = $1;
                        while(last->next_column != NULL)
                            last = last->next_column;
                        last->next_column = temp;
                        $$ = $1;
                    }
                }
            ;

values      :   value
                {
                    $$ = $1;
                }
            |   values ',' value
                {
                    if(!$1)
                        $$ = $3;
                    else{
                        struct insert_value *last = $1;
                        while(last->next_value != NULL)
                            last = last->next_value;
                        last->next_value = $3;
                        $$ = $1;
                    }
                }
            ;

value       :   SINGLE_QUOTE IDENTIFIER SINGLE_QUOTE
                {
                    $$ = (struct insert_value*)malloc(sizeof(struct insert_value));
                    $$->value = strdup($2);
                    $$->type = CHAR;
                    $$->next_value = NULL;
                }
            |   NUMBER
                {
                    $$ = (struct insert_value*)malloc(sizeof(struct insert_value));
                    $$->value = strdup($1);
                    $$->type = INT;
                    $$->next_value = NULL;
                }
            ;

select_sql  :   KW_SELECT STAR KW_FROM tables where_clause ';'                                  {printf("识别到select语句\n");}
            |   KW_SELECT columns KW_FROM tables where_clause ';'                               {printf("识别到select语句\n");}
            ;

delete_sql  :   KW_DELETE KW_FROM IDENTIFIER where_clause ';'                                   {printf("识别到delete语句\n");};

update_sql  :   KW_UPDATE IDENTIFIER KW_SET results where_clause ';'                            {printf("识别到update语句\n");};

tables      :   IDENTIFIER
            |   tables ',' IDENTIFIER
            ;

results     :   result
            |   results ',' result
            ;

result      :   IDENTIFIER '=' SINGLE_QUOTE IDENTIFIER SINGLE_QUOTE
            |   IDENTIFIER '=' NUMBER
            ;

where_clause:
            |   KW_WHERE conditions
            ;

/******************Grammar1: generated by deepseek******************/
// conditions  :   logical_and_conditions
//             |   conditions KW_OR logical_and_conditions
//             ;

// logical_and_conditions  
//             :   logical_and_conditions KW_AND primary_condition
//             |   primary_condition
//             ;

// primary_condition   
//             :   '(' conditions ')'
//             |   condition
//             ;
/*******************************************************************/

/*********************Grammar2: wrote by myself*********************/
conditions  :   conditions KW_AND base_conditions
            |   conditions KW_OR base_conditions
            |   base_conditions
            ;

base_conditions 
            :   '(' conditions ')'
            |   condition
            ;
/*******************************************************************/

/*******************************Notes*******************************/
//Deepseek:
//文法1通过规则分层显式表达优先级逻辑，更符合直觉，减少对优先级声明的依赖;
//文法2依赖优先级声明，规则本身较为扁平，可读性和扩展性较弱
/*******************************************************************/

condition   :   IDENTIFIER '=' NUMBER
            |   IDENTIFIER '=' SINGLE_QUOTE IDENTIFIER SINGLE_QUOTE
            |   IDENTIFIER '>' NUMBER
            |   IDENTIFIER '<' NUMBER
            |   IDENTIFIER NOT_EQUAL NUMBER
            |   IDENTIFIER NOT_EQUAL SINGLE_QUOTE IDENTIFIER SINGLE_QUOTE
            |   IDENTIFIER LESS_OR_EQUAL NUMBER
            |   IDENTIFIER GREATER_OR_EQUAL NUMBER
            ;

%%

int main(){
    printf("%s>", pwd);
    yyparse();
    return 0;
}

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}