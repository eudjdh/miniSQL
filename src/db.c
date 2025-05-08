#include "db.h"

const char *root_path = "/home/tom/Documents/compiling/miniSQL/";
char pwd[256] = "database";

int create_database(struct create_struct *cr_var){
    if(strcmp(pwd, "database") != 0)
        return 3;
    
    FILE *fp;
    char sysdat_path[512];
    char newdir_path[512];
    char line[256];

    snprintf(sysdat_path, sizeof(sysdat_path), "%s%s/sys.dat", root_path, pwd);
    fp = fopen(sysdat_path, "a+");
    if (!fp) {
        perror("sys.dat");
        return -1;
    }
    // 打开sys.dat文件，逐行扫描是否有同名数据库，若有则返回2
    rewind(fp);
    while (fgets(line, sizeof(line), fp)) {
        char *nl = strchr(line, '\n');
        if (nl) *nl = '\0';
        if (strcmp(line, cr_var->name) == 0) {
            fclose(fp);
            return 2;
        }
    }
    // 没有同名数据库，添加一行
    fprintf(fp, "%s\n", cr_var->name);
    fflush(fp);
    fclose(fp);
    // 创建该库的目录
    snprintf(newdir_path, sizeof(newdir_path), "%s%s/%s", root_path, pwd, cr_var->name);
    if(mkdir(newdir_path, 0755) != 0){
        perror("创建目录失败");
    }
    return 1;
}

int create_table(struct create_struct *cr_var){
    return 1;
}

void free_create_struct(struct create_struct *cr_var){
    if (!cr_var) return;
    if (cr_var->name)           free(cr_var->name);
    if (cr_var->entries_list)   free_create_entries(cr_var->entries_list);
    free(cr_var);
}

void free_create_entries(struct create_table_entries* entries_list){
    while(entries_list){
        struct create_table_entries *next = entries_list->next_entry;
        free(entries_list->entry_name);
        free(entries_list);
        entries_list = next;
    }
}