#ifndef DB_H
#define DB_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>

// create语句相关结构体
enum OBJTYPE{DATABASE, TABLE};
enum DATATYPE{INT, CHAR};
struct create_table_entries{
    char *entry_name;                           // 列名
    enum DATATYPE entry_type;                   // 列类型
    int length;                                 // 长度（若为int类型则忽略）
    struct create_table_entries *next_entry;          // 下一个列
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

extern char pwd[256];

int create_database(struct create_struct *cr_var);
int create_table(struct create_struct *cr_var);
void free_create_struct(struct create_struct *cr_var);
void free_create_entries(struct create_table_entries* entries_list);

int use_database(struct use_struct *use_var);
void free_use_struct(struct use_struct *use_var);

#endif