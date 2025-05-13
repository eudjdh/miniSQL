#ifndef DB_H
#define DB_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <dirent.h>
#include <unistd.h>
#include <limits.h>

#define TRUE 1
#define FALSE 0

enum OBJTYPE    {DATABASE, TABLE};
enum DATATYPE   {INT, CHAR};
enum NODETYPE   {COMPARISON, COLUMN, VALUE};
enum COMP_OP    {AND, OR, EQ, NOT_EQ, GREATER, LESS, GREATER_OR_EQ, LESS_OR_EQ};

// create语句相关结构体
struct create_table_entries{
    char *entry_name;                           // 列名
    enum DATATYPE entry_type;                   // 列类型
    int length;                                 // 长度（若为int类型则忽略）
    struct create_table_entries *next_entry;    // 下一个列
};
struct create_struct{
    char *name;                                 // 数据库名或表名
    enum OBJTYPE object_type;                   // 操作对象类型，数据库或表
    struct create_table_entries *entries_list;  // 列链表
};

// use语句相关结构体
struct use_struct{
    char *db_name;
};

// show语句相关结构体
struct show_struct{
    enum OBJTYPE object_type;
};

// drop语句相关结构体
struct drop_struct{
    char *name;
    enum OBJTYPE object_type;
};

// insert语句相关结构体
struct insert_value{
    char *value;                                // 基本数据的值
    enum DATATYPE type;                         // 数据类型
    struct insert_value* next_value;            // 下一个基本数据
};
struct insert_column{
    char *name;
    struct insert_column *next_column;
};
struct insert_struct{
    char *table_name;                           // 待插入的表名
    struct insert_column *columns;              // 列链表
    struct insert_value *values;                // 值链表
};

// delete语句相关结构体
struct delete_struct{
    char *table_name;
    struct condition *conditions;
};

// update语句相关结构体
struct result{
    char *column_name;
    enum DATATYPE type;
    union {
        int num_val;
        char *str_val;
    };
    struct result *next_result;
};
struct update_struct{
    char *table_name;
    struct result *results;
    struct condition *conditions;
};

// select语句相关结构体
struct column{
    char *table_name;
    char *column_name;
    struct column *next_column;
};
struct table{
    char *table_name;
    struct table *next_table;
};
struct select_struct{
    struct column *columns;
    struct table *tables;
    struct condition *conditions;
};

// where子句的条件相关结构体
struct cmpdata{
    enum DATATYPE type;
    union{
        int num_val;
        char *str_val;
    };
};
struct condition{
    struct condition *left;                     // 左部条件
    struct condition *right;                    // 有部条件
    enum NODETYPE type;                         // 结点类型：比较符、列、值
    union {
        char *column_name;
        enum COMP_OP op;                        // 比较符号种类
        struct cmpdata *data;
    };
    char *table_name;                           // 条件中的表名
};

// 读取现有记录的结构体，用于where子句中的比较
struct record{
    char *table_name;
    char *column_name;
    int index;
    enum DATATYPE type;
    union{
        int num_val;
        char *str_val;
    };
    struct record *next;
};

extern char pwd[256];

int create_database(struct create_struct *);
int create_table(struct create_struct *);
void free_create_struct(struct create_struct *);
void free_create_entries(struct create_table_entries* );

int use_database(struct use_struct *);
void free_use_struct(struct use_struct *);

int show_database(struct show_struct *);
int show_table(struct show_struct *);
void free_show_struct(struct show_struct *);

int drop_database(struct drop_struct* );
int drop_table(struct drop_struct* );
int remove_dir(const char *);
void free_drop_struct(struct drop_struct* );

int insert_data(struct insert_struct* );
void free_insert_struct(struct insert_struct* );

int delete_data(struct delete_struct *);
void free_delete_struct(struct delete_struct *);

int update_data(struct update_struct *);
void free_update_struct(struct update_struct *);
void free_update_results(struct result *);

int select_data(struct select_struct *);
struct record *create_new_row(struct record *);
void free_select_struct(struct select_struct *);
void free_select_columns(struct column *);
void free_select_tables(struct table *);

int evaluate_condition(struct record *, struct condition *, int *);
int evaluate_comparison(struct record *, struct condition *, int *);
void free_condition_tree(struct condition *);

void free_records(struct record *);

#endif