%{
    #include "db.h"
    extern int yylex(void);
    extern void yyerror(const char *s);
%}

%union{
    char *str_val;                              // 字符串值，数字和标识符都以字符串存储操作，仅有涉及比较时才会转换为数字
    struct create_struct *create_var;           // create语句的值
    struct create_table_entries *entries_var;   // create table的列链表
    struct use_struct *use_var;                 // use语句的值
    struct show_struct *show_var;               // show语句的值
    struct drop_struct *drop_var;               // drop语句的值
    struct insert_value *value_var;             // insert语句中的values
    struct insert_column *column_var;           // insert语句中的columns
    struct insert_struct *insert_var;           // insert语句的值
    struct condition *conditions;               // where子句中的条件
    struct delete_struct *delete_var;           // delete语句的值
    struct result *results;                     // 需要修改成的结果
    struct update_struct *update_var;           // update语句的值
    struct table *select_tables;                // select语句挑选的表
    struct column *select_columns;              // select语句挑选的列
    struct select_struct *select_var;           // select语句的值
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
%type <conditions> condition conditions where_clause
%type <delete_var> delete_sql
%type <results> results result
%type <update_var> update_sql
%type <select_tables> tables
%type <select_columns> fields field
%type <select_var> select_sql

%token NOT_EQUAL '=' '<' '>' ';' ',' '(' ')' GREATER_OR_EQUAL LESS_OR_EQUAL '.'
%token SINGLE_QUOTE STAR KW_CHAR KW_INT KW_CREATE KW_TABLE KW_DATABASE KW_DATABASES
%token KW_SHOW KW_TABLES KW_USE KW_DROP KW_INSERT KW_INTO KW_VALUES KW_SELECT
%token KW_FROM KW_WHERE KW_AND KW_OR KW_DELETE KW_UPDATE KW_SET EXIT UNKNOWN
%left  KW_OR
%left  KW_AND
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
                    else if(result == 7)
                        printf("数据数量与列数量不匹配\n");
                    else
                        printf("插入数据失败\n");
                    free_insert_struct($1);
                }
            |   select_sql
                {
                    int result = select_data($1);
                    if(result == 1)
                        printf("数据打印完毕\n");
                    else if(result == 2)
                        printf("表不存在\n");
                    else if(result == 3)
                        printf("请进入数据库进行查询\n");
                    else if(result == 4)
                        printf("列不存在\n");
                    else
                        printf("查询数据失败\n");
                    free_select_struct($1);
                }
            |   delete_sql
                {
                    int result;
                    result = delete_data($1);
                    if(result == 1)
                        printf("删除数据成功\n");
                    else if(result == 2)
                        printf("表%s不存在\n", $1->table_name);
                    else if(result == 3)
                        printf("请进入数据库删除数据\n");
                    else if(result == 4)
                        printf("列不存在\n");
                    else if(result == 5)
                        printf("表%s为空\n", $1->table_name);
                    else
                        printf("删除数据失败\n");
                    free_delete_struct($1);
                }
            |   update_sql 
                {
                    int result = update_data($1);
                    if(result == 1)
                        printf("修改数据成功\n");
                    else if(result == 2)
                        printf("表%s不存在\n", $1->table_name);
                    else if(result == 3)
                        printf("请进入数据库更新数据\n");
                    else if(result == 4)
                        printf("列不存在\n");
                    else if(result == 5)
                        printf("表%s为空\n", $1->table_name);
                    else if(result == 6)
                        printf("类型不匹配\n");
                    else
                        printf("更新数据失败\n");
                    free_update_struct($1);
                }
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

select_sql  :   KW_SELECT STAR KW_FROM tables where_clause ';'                                  
                {
                    $$ = (struct select_struct*)malloc(sizeof(struct select_struct));
                    $$->columns = NULL;
                    $$->tables = $4;
                    $$->conditions = $5;
                }
            |   KW_SELECT fields KW_FROM tables where_clause ';'                                
                {
                    $$ = (struct select_struct*)malloc(sizeof(struct select_struct));
                    $$->columns = $2;
                    $$->tables = $4;
                    $$->conditions = $5;
                }
            ;

tables      :   IDENTIFIER
                {
                    $$ = (struct table*)malloc(sizeof(struct table));
                    $$->table_name = strdup($1);
                    $$->next_table = NULL;
                }
            |   tables ',' IDENTIFIER
                {
                    struct table *new_table = (struct table*)malloc(sizeof(struct table));
                    new_table->table_name = strdup($3);
                    new_table->next_table = NULL;
                    if(!$1) $$ = new_table;
                    else{
                        struct table *last = $1;
                        while(last->next_table) last = last->next_table;
                        last->next_table = new_table;
                        $$ = $1;
                    }
                }
            ;

fields      :   field
                {
                    $$ = $1;
                }
            |   fields ',' field
                {
                    if(!$1) $$ = $3;
                    else{
                        struct column *last = $1;
                        while(last->next_column)   last = last->next_column;
                        last->next_column = $3;
                        $$ = $1;
                    }
                }
            ;

field       :   IDENTIFIER
                {
                    $$ = (struct column*)malloc(sizeof(struct column));
                    $$->table_name = NULL;
                    $$->column_name = strdup($1);
                    $$->next_column = NULL;
                }
            |   IDENTIFIER '.' IDENTIFIER
                {
                    $$ = (struct column*)malloc(sizeof(struct column));
                    $$->table_name = strdup($1);
                    $$->column_name = strdup($3);
                    $$->next_column = NULL;
                }
            ;

delete_sql  :   KW_DELETE KW_FROM IDENTIFIER where_clause ';'                                   
                {
                    $$ = (struct delete_struct *)malloc(sizeof(struct delete_struct));
                    $$->table_name = strdup($3);
                    $$->conditions = $4;
                }
            ;

update_sql  :   KW_UPDATE IDENTIFIER KW_SET results where_clause ';'                            
                {
                    $$ = (struct update_struct*)malloc(sizeof(struct update_struct));
                    $$->table_name = strdup($2);
                    $$->results = $4;
                    $$->conditions = $5;
                }
            ;

results     :   result
                {
                    $$ = $1;
                }
            |   results ',' result
                {
                    if(!$1)
                        $$ = $3;
                    else{
                        struct result *last = $1;
                        while(last->next_result != NULL)
                            last = last->next_result;
                        last->next_result = $3;
                        $$ = $1;
                    }
                }
            ;

result      :   IDENTIFIER '=' SINGLE_QUOTE IDENTIFIER SINGLE_QUOTE
                {
                    $$ = (struct result*)malloc(sizeof(struct result));
                    $$->column_name = strdup($1);
                    $$->type = CHAR;
                    $$->str_val = strdup($4);
                    $$->next_result = NULL;
                }
            |   IDENTIFIER '=' NUMBER
                {
                    $$ = (struct result*)malloc(sizeof(struct result));
                    $$->column_name = strdup($1);
                    $$->type = INT;
                    $$->num_val = atoi($3);
                    $$->next_result = NULL;
                }
            ;

where_clause:
                {
                    $$ = NULL;
                }
            |   KW_WHERE conditions
                {
                    $$ = $2;
                }
            ;

conditions  :   condition
                {
                    $$ = $1;
                }
            |   '(' conditions ')'
                {
                    $$ = $2;
                }
            |   conditions KW_AND conditions
                {
                    $$ = (struct condition*)malloc(sizeof(struct condition));
                    $$->left = $1;
                    $$->right = $3;
                    $$->type = COMPARISON;
                    $$->op = AND;
                    $$->table_name = NULL;
                }
            |   conditions KW_OR conditions
                {
                    $$ = (struct condition*)malloc(sizeof(struct condition));
                    $$->left = $1;
                    $$->right = $3;
                    $$->type = COMPARISON;
                    $$->op = OR;
                    $$->table_name = NULL;
                }
            ;

condition   :   IDENTIFIER '=' NUMBER
                {
                    struct condition *left = (struct condition*)malloc(sizeof(struct condition));
                    left->left = NULL;
                    left->right = NULL;
                    left->type = COLUMN;
                    left->column_name = strdup($1);
                    left->table_name = NULL;
                    struct condition *right = (struct condition*)malloc(sizeof(struct condition));
                    right->left = NULL;
                    right->right = NULL;
                    right->type = VALUE;
                    right->data = (struct cmpdata*)malloc(sizeof(struct cmpdata));
                    right->data->type = INT;
                    right->data->num_val = atoi($3);
                    right->table_name = NULL;
                    $$ = (struct condition*)malloc(sizeof(struct condition));
                    $$->left = left;
                    $$->right = right;
                    $$->type = COMPARISON;
                    $$->op = EQ;
                    $$->table_name = NULL;
                }
            |   IDENTIFIER '=' SINGLE_QUOTE IDENTIFIER SINGLE_QUOTE
                {
                    struct condition *left = (struct condition*)malloc(sizeof(struct condition));
                    left->left = NULL;
                    left->right = NULL;
                    left->type = COLUMN;
                    left->column_name = strdup($1);
                    left->table_name = NULL;
                    struct condition *right = (struct condition*)malloc(sizeof(struct condition));
                    right->left = NULL;
                    right->right = NULL;
                    right->type = VALUE;
                    right->data = (struct cmpdata*)malloc(sizeof(struct cmpdata));
                    right->data->type = CHAR;
                    right->data->str_val = strdup($4);
                    right->table_name = NULL;
                    $$ = (struct condition*)malloc(sizeof(struct condition));
                    $$->left = left;
                    $$->right = right;
                    $$->type = COMPARISON;
                    $$->op = EQ;
                    $$->table_name = NULL;
                }
            |   IDENTIFIER '>' NUMBER
                {
                    struct condition *left = (struct condition*)malloc(sizeof(struct condition));
                    left->left = NULL;
                    left->right = NULL;
                    left->type = COLUMN;
                    left->column_name = strdup($1);
                    left->table_name = NULL;
                    struct condition *right = (struct condition*)malloc(sizeof(struct condition));
                    right->left = NULL;
                    right->right = NULL;
                    right->type = VALUE;
                    right->data = (struct cmpdata*)malloc(sizeof(struct cmpdata));
                    right->data->type = INT;
                    right->data->num_val = atoi($3);
                    right->table_name = NULL;
                    $$ = (struct condition*)malloc(sizeof(struct condition));
                    $$->left = left;
                    $$->right = right;
                    $$->type = COMPARISON;
                    $$->op = GREATER;
                    $$->table_name = NULL;
                }
            |   IDENTIFIER '<' NUMBER
                {
                    struct condition *left = (struct condition*)malloc(sizeof(struct condition));
                    left->left = NULL;
                    left->right = NULL;
                    left->type = COLUMN;
                    left->column_name = strdup($1);
                    left->table_name = NULL;
                    struct condition *right = (struct condition*)malloc(sizeof(struct condition));
                    right->left = NULL;
                    right->right = NULL;
                    right->type = VALUE;
                    right->data = (struct cmpdata*)malloc(sizeof(struct cmpdata));
                    right->data->type = INT;
                    right->data->num_val = atoi($3);
                    right->table_name = NULL;
                    $$ = (struct condition*)malloc(sizeof(struct condition));
                    $$->left = left;
                    $$->right = right;
                    $$->type = COMPARISON;
                    $$->op = LESS;
                    $$->table_name = NULL;
                }
            |   IDENTIFIER NOT_EQUAL NUMBER
                {
                    struct condition *left = (struct condition*)malloc(sizeof(struct condition));
                    left->left = NULL;
                    left->right = NULL;
                    left->type = COLUMN;
                    left->column_name = strdup($1);
                    left->table_name = NULL;
                    struct condition *right = (struct condition*)malloc(sizeof(struct condition));
                    right->left = NULL;
                    right->right = NULL;
                    right->type = VALUE;
                    right->data = (struct cmpdata*)malloc(sizeof(struct cmpdata));
                    right->data->type = INT;
                    right->data->num_val = atoi($3);
                    right->table_name = NULL;
                    $$ = (struct condition*)malloc(sizeof(struct condition));
                    $$->left = left;
                    $$->right = right;
                    $$->type = COMPARISON;
                    $$->op = NOT_EQ;
                    $$->table_name = NULL;
                }
            |   IDENTIFIER NOT_EQUAL SINGLE_QUOTE IDENTIFIER SINGLE_QUOTE
                {
                    struct condition *left = (struct condition*)malloc(sizeof(struct condition));
                    left->left = NULL;
                    left->right = NULL;
                    left->type = COLUMN;
                    left->column_name = strdup($1);
                    left->table_name = NULL;
                    struct condition *right = (struct condition*)malloc(sizeof(struct condition));
                    right->left = NULL;
                    right->right = NULL;
                    right->type = VALUE;
                    right->data = (struct cmpdata*)malloc(sizeof(struct cmpdata));
                    right->data->type = CHAR;
                    right->data->str_val = strdup($4);
                    right->table_name = NULL;
                    $$ = (struct condition*)malloc(sizeof(struct condition));
                    $$->left = left;
                    $$->right = right;
                    $$->type = COMPARISON;
                    $$->op = NOT_EQ;
                    $$->table_name = NULL;
                }
            |   IDENTIFIER LESS_OR_EQUAL NUMBER
                {
                    struct condition *left = (struct condition*)malloc(sizeof(struct condition));
                    left->left = NULL;
                    left->right = NULL;
                    left->type = COLUMN;
                    left->column_name = strdup($1);
                    left->table_name = NULL;
                    struct condition *right = (struct condition*)malloc(sizeof(struct condition));
                    right->left = NULL;
                    right->right = NULL;
                    right->type = VALUE;
                    right->data = (struct cmpdata*)malloc(sizeof(struct cmpdata));
                    right->data->type = INT;
                    right->data->num_val = atoi($3);
                    right->table_name = NULL;
                    $$ = (struct condition*)malloc(sizeof(struct condition));
                    $$->left = left;
                    $$->right = right;
                    $$->type = COMPARISON;
                    $$->op = LESS_OR_EQ;
                    $$->table_name = NULL;
                }
            |   IDENTIFIER GREATER_OR_EQUAL NUMBER
                {
                    struct condition *left = (struct condition*)malloc(sizeof(struct condition));
                    left->left = NULL;
                    left->right = NULL;
                    left->type = COLUMN;
                    left->column_name = strdup($1);
                    left->table_name = NULL;
                    struct condition *right = (struct condition*)malloc(sizeof(struct condition));
                    right->left = NULL;
                    right->right = NULL;
                    right->type = VALUE;
                    right->data = (struct cmpdata*)malloc(sizeof(struct cmpdata));
                    right->data->type = INT;
                    right->data->num_val = atoi($3);
                    right->table_name = NULL;
                    $$ = (struct condition*)malloc(sizeof(struct condition));
                    $$->left = left;
                    $$->right = right;
                    $$->type = COMPARISON;
                    $$->op = GREATER_OR_EQ;
                    $$->table_name = NULL;
                }
            |   IDENTIFIER '.' IDENTIFIER '=' NUMBER
                {
                    struct condition *left = (struct condition*)malloc(sizeof(struct condition));
                    left->left = NULL;
                    left->right = NULL;
                    left->type = COLUMN;
                    left->column_name = strdup($3);
                    left->table_name = strdup($1);
                    struct condition *right = (struct condition*)malloc(sizeof(struct condition));
                    right->left = NULL;
                    right->right = NULL;
                    right->type = VALUE;
                    right->data = (struct cmpdata*)malloc(sizeof(struct cmpdata));
                    right->data->type = INT;
                    right->data->num_val = atoi($5);
                    right->table_name = NULL;
                    $$ = (struct condition*)malloc(sizeof(struct condition));
                    $$->left = left;
                    $$->right = right;
                    $$->type = COMPARISON;
                    $$->op = EQ;
                    $$->table_name = NULL;
                }
            |   IDENTIFIER '.' IDENTIFIER '=' SINGLE_QUOTE IDENTIFIER SINGLE_QUOTE
                {
                    struct condition *left = (struct condition*)malloc(sizeof(struct condition));
                    left->left = NULL;
                    left->right = NULL;
                    left->type = COLUMN;
                    left->column_name = strdup($3);
                    left->table_name = strdup($1);
                    struct condition *right = (struct condition*)malloc(sizeof(struct condition));
                    right->left = NULL;
                    right->right = NULL;
                    right->type = VALUE;
                    right->data = (struct cmpdata*)malloc(sizeof(struct cmpdata));
                    right->data->type = CHAR;
                    right->data->str_val = strdup($6);
                    right->table_name = NULL;
                    $$ = (struct condition*)malloc(sizeof(struct condition));
                    $$->left = left;
                    $$->right = right;
                    $$->type = COMPARISON;
                    $$->op = EQ;
                    $$->table_name = NULL;
                }
            |   IDENTIFIER '.' IDENTIFIER '>' NUMBER
                {
                    struct condition *left = (struct condition*)malloc(sizeof(struct condition));
                    left->left = NULL;
                    left->right = NULL;
                    left->type = COLUMN;
                    left->column_name = strdup($3);
                    left->table_name = strdup($1);
                    struct condition *right = (struct condition*)malloc(sizeof(struct condition));
                    right->left = NULL;
                    right->right = NULL;
                    right->type = VALUE;
                    right->data = (struct cmpdata*)malloc(sizeof(struct cmpdata));
                    right->data->type = INT;
                    right->data->num_val = atoi($5);
                    right->table_name = NULL;
                    $$ = (struct condition*)malloc(sizeof(struct condition));
                    $$->left = left;
                    $$->right = right;
                    $$->type = COMPARISON;
                    $$->op = GREATER;
                    $$->table_name = NULL;
                }
            |   IDENTIFIER '.' IDENTIFIER '<' NUMBER
                {
                    struct condition *left = (struct condition*)malloc(sizeof(struct condition));
                    left->left = NULL;
                    left->right = NULL;
                    left->type = COLUMN;
                    left->column_name = strdup($3);
                    left->table_name = strdup($1);
                    struct condition *right = (struct condition*)malloc(sizeof(struct condition));
                    right->left = NULL;
                    right->right = NULL;
                    right->type = VALUE;
                    right->data = (struct cmpdata*)malloc(sizeof(struct cmpdata));
                    right->data->type = INT;
                    right->data->num_val = atoi($5);
                    right->table_name = NULL;
                    $$ = (struct condition*)malloc(sizeof(struct condition));
                    $$->left = left;
                    $$->right = right;
                    $$->type = COMPARISON;
                    $$->op = LESS;
                    $$->table_name = NULL;
                }
            |   IDENTIFIER '.' IDENTIFIER NOT_EQUAL NUMBER
                {
                    struct condition *left = (struct condition*)malloc(sizeof(struct condition));
                    left->left = NULL;
                    left->right = NULL;
                    left->type = COLUMN;
                    left->column_name = strdup($3);
                    left->table_name = strdup($1);
                    struct condition *right = (struct condition*)malloc(sizeof(struct condition));
                    right->left = NULL;
                    right->right = NULL;
                    right->type = VALUE;
                    right->data = (struct cmpdata*)malloc(sizeof(struct cmpdata));
                    right->data->type = INT;
                    right->data->num_val = atoi($5);
                    right->table_name = NULL;
                    $$ = (struct condition*)malloc(sizeof(struct condition));
                    $$->left = left;
                    $$->right = right;
                    $$->type = COMPARISON;
                    $$->op = NOT_EQ;
                    $$->table_name = NULL;
                }
            |   IDENTIFIER '.' IDENTIFIER NOT_EQUAL SINGLE_QUOTE IDENTIFIER SINGLE_QUOTE
                {
                    struct condition *left = (struct condition*)malloc(sizeof(struct condition));
                    left->left = NULL;
                    left->right = NULL;
                    left->type = COLUMN;
                    left->column_name = strdup($3);
                    left->table_name = strdup($1);
                    struct condition *right = (struct condition*)malloc(sizeof(struct condition));
                    right->left = NULL;
                    right->right = NULL;
                    right->type = VALUE;
                    right->data = (struct cmpdata*)malloc(sizeof(struct cmpdata));
                    right->data->type = CHAR;
                    right->data->str_val = strdup($6);
                    right->table_name = NULL;
                    $$ = (struct condition*)malloc(sizeof(struct condition));
                    $$->left = left;
                    $$->right = right;
                    $$->type = COMPARISON;
                    $$->op = NOT_EQ;
                    $$->table_name = NULL;
                }
            |   IDENTIFIER '.' IDENTIFIER LESS_OR_EQUAL NUMBER
                {
                    struct condition *left = (struct condition*)malloc(sizeof(struct condition));
                    left->left = NULL;
                    left->right = NULL;
                    left->type = COLUMN;
                    left->column_name = strdup($3);
                    left->table_name = strdup($1);
                    struct condition *right = (struct condition*)malloc(sizeof(struct condition));
                    right->left = NULL;
                    right->right = NULL;
                    right->type = VALUE;
                    right->data = (struct cmpdata*)malloc(sizeof(struct cmpdata));
                    right->data->type = INT;
                    right->data->num_val = atoi($5);
                    right->table_name = NULL;
                    $$ = (struct condition*)malloc(sizeof(struct condition));
                    $$->left = left;
                    $$->right = right;
                    $$->type = COMPARISON;
                    $$->op = LESS_OR_EQ;
                    $$->table_name = NULL;
                }
            |   IDENTIFIER '.' IDENTIFIER GREATER_OR_EQUAL NUMBER
                {
                    struct condition *left = (struct condition*)malloc(sizeof(struct condition));
                    left->left = NULL;
                    left->right = NULL;
                    left->type = COLUMN;
                    left->column_name = strdup($3);
                    left->table_name = strdup($1);
                    struct condition *right = (struct condition*)malloc(sizeof(struct condition));
                    right->left = NULL;
                    right->right = NULL;
                    right->type = VALUE;
                    right->data = (struct cmpdata*)malloc(sizeof(struct cmpdata));
                    right->data->type = INT;
                    right->data->num_val = atoi($5);
                    right->table_name = NULL;
                    $$ = (struct condition*)malloc(sizeof(struct condition));
                    $$->left = left;
                    $$->right = right;
                    $$->type = COMPARISON;
                    $$->op = GREATER_OR_EQ;
                    $$->table_name = NULL;
                }
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