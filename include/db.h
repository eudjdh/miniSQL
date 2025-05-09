#ifndef DB_H
#define DB_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <dirent.h>
#include <unistd.h>
#include <assert.h>

enum OBJTYPE{DATABASE, TABLE};
enum DATATYPE{INT, CHAR};

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

extern char pwd[256];

int create_database(struct create_struct *cr_var);
int create_table(struct create_struct *cr_var);
void free_create_struct(struct create_struct *cr_var);
void free_create_entries(struct create_table_entries* entries_list);

int use_database(struct use_struct *use_var);
void free_use_struct(struct use_struct *use_var);

int show_database(struct show_struct *show_var);
int show_table(struct show_struct *show_var);
void free_show_struct(struct show_struct *show_var);

int drop_database(struct drop_struct* drop_var);
int drop_table(struct drop_struct* drop_var);
int remove_dir(const char *dir_path);
void free_drop_struct(struct drop_struct* drop_var);

int insert_data(struct insert_struct* insert_var);
void free_insert_struct(struct insert_struct* insert_var);

#endif