#ifndef DB_H
#define DB_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>

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

extern char pwd[256];

int create_database(struct create_struct *cr_var);
int create_table(struct create_struct *cr_var);
void free_create_struct(struct create_struct *cr_var);
void free_create_entries(struct create_table_entries* entries_list);

#endif