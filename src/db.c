#include "db.h"

const char *root_path = "/home/tom/Documents/compiling/miniSQL/";
const char *db_sysdat_path = "/home/tom/Documents/compiling/miniSQL/database/sys.dat";
char pwd[256] = "database";

/*****************************create******************************************/
int create_database(struct create_struct *cr_var){
    if(strcmp(pwd, "database") != 0)
        return 3;
    
    char newdir_path[512];
    char line[256];

    FILE *fp = fopen(db_sysdat_path, "a+");
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
        perror("创建数据库目录失败");
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
/*****************************************************************************/

/*********************************use*****************************************/
int use_database(struct use_struct *use_var){
    FILE *fp = fopen(db_sysdat_path, "r");
    char line[256];
    if (!fp) {
        perror("sys.dat");
        return -1;
    }
    // 逐行扫描sys.dat是否有同名数据库，若有则改变pwd，并返回1
    rewind(fp);
    while (fgets(line, sizeof(line), fp)) {
        char *nl = strchr(line, '\n');
        if (nl) *nl = '\0';
        if (strcmp(line, use_var->db_name) == 0) {
            snprintf(pwd, sizeof(pwd), "database/%s", use_var->db_name);
            return 1;
        }
    }
    return 2;
}

void free_use_struct(struct use_struct *use_var){
    if(!use_var)    return;
    if(use_var->db_name)    free(use_var->db_name);
    free(use_var);
}