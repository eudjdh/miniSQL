#include "db.h"

const char *root_path = "/home/tom/Documents/compiling/miniSQL/";
const char *db_sysdat_path = "/home/tom/Documents/compiling/miniSQL/database/sys.dat";
const char *temp_db_sysdat_path = "/home/tom/Documents/compiling/miniSQL/database/temp.dat";
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
    if(strcmp(pwd, "database") == 0)
        return 3;
    
    char sysdat_path[512];
    char newfile_path[512];
    char line[256];
    // 查询是否有同名表存在
    snprintf(sysdat_path, sizeof(sysdat_path), "%s%s/sys.dat", root_path, pwd);
    FILE *fp = fopen(sysdat_path, "a+");
    if (!fp) {
        perror("sys.dat");
        return -1;
    }
    rewind(fp);
    while(fgets(line, sizeof(line), fp)){
        char *whitespace = strchr(line, ' ');
        if (whitespace) *whitespace = '\0';
        if(strcmp(line, cr_var->name) == 0){
            fclose(fp);
            return 2;
        }
    }
    // 没有同名表，创建新表
    int col_index = 1; // 自增的元数据序号
    struct create_table_entries *cur_entry = cr_var->entries_list;
    while(cur_entry){
        if(cur_entry->entry_type == INT){
            snprintf(line, sizeof(line), "%s %d %s int", cr_var->name, col_index, cur_entry->entry_name);
            fprintf(fp, "%s\n", line);
            fflush(fp);
        }
        else if(cur_entry->entry_type == CHAR){
            snprintf(line, sizeof(line), "%s %d %s char %d", cr_var->name, col_index, cur_entry->entry_name, cur_entry->length);
            fprintf(fp, "%s\n", line);
            fflush(fp);
        }
        cur_entry = cur_entry->next_entry;
        col_index++;
    }
    fclose(fp);
    // 创建新表的txt文件
    snprintf(newfile_path, sizeof(newfile_path), "%s%s/%s.txt", root_path, pwd, cr_var->name);
    FILE *newfile_fp = fopen(newfile_path, "w");
    fclose(newfile_fp);
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
/*****************************************************************************/

/**********************************show***************************************/
int show_database(struct show_struct *show_var){
    if(strcmp(pwd, "database") != 0)
        return 2;
    
    printf("databases:\n");

    FILE *fp = fopen(db_sysdat_path, "r");
    if(!fp){
        perror("sys.dat");
        return -1;
    }
    char database[256];
    rewind(fp);
    while(fgets(database, sizeof(database), fp)){
        char *nl = strchr(database, '\n');
        if (nl) *nl = '\0';
        printf("%s\n", database);
    }
    return 1;
}

int show_table(struct show_struct *show_var){
    if(strcmp(pwd, "database") == 0)
        return 2;
    
    printf("tables:\n");

    char sysdat_path[512];
    char new_line[256];
    char old_name[256] = {'\0'};
    snprintf(sysdat_path, sizeof(sysdat_path), "%s%s/sys.dat", root_path, pwd);
    FILE *fp = fopen(sysdat_path, "r");
    if (!fp) {
        perror("sys.dat");
        return -1;
    }
    rewind(fp);
    while(fgets(new_line, sizeof(new_line), fp)){
        char *whitespace = strchr(new_line, ' ');
        if (whitespace) *whitespace = '\0';
        if(strcmp(old_name, new_line) == 0)
            continue;
        else{
            printf("%s\n", new_line);
            strncpy(old_name, new_line, sizeof(new_line));
        }
    }
    return 1;
}

void free_show_struct(struct show_struct *show_var){
    free(show_var);
}
/*****************************************************************************/

/**********************************drop***************************************/
int drop_database(struct drop_struct *drop_var){
    if(strcmp(pwd, "database") != 0)
        return 3;
    
    int success = 2;
    char database[256];
    char remove_dir_path[512];
    FILE *old_fp = fopen(db_sysdat_path, "r");
    if(!old_fp){
        perror("sys.dat");
        return -1;
    }
    FILE *new_fp = fopen(temp_db_sysdat_path, "w");
    if(!new_fp){
        perror("temp.dat");
        return -1;
    }
    rewind(new_fp);
    rewind(old_fp);
    while(fgets(database, sizeof(database), old_fp)){
        char *nl = strchr(database, '\n');
        if(nl) *nl = '\0';
        if(strcmp(database, drop_var->name) == 0){
            success = 1;
            continue;
        }
        else
            fprintf(new_fp, "%s\n", database);
    }
    fclose(old_fp);
    fclose(new_fp);
    // 删除源文件
    if (remove(db_sysdat_path) != 0) {
        perror("删除原文件出错");
        return -1;
    }
    // 改名新文件
    if (rename(temp_db_sysdat_path, db_sysdat_path) != 0) {
        perror("重命名临时文件出错");
        return -1;
    }
    // 删除数据库对应文件夹
    if(success == 1){
        snprintf(remove_dir_path, sizeof(remove_dir_path), "%s%s/%s", root_path, pwd, drop_var->name);
        remove_dir(remove_dir_path);
    }
    return success;
}

int remove_dir(const char *dir_path){
    DIR *dir;
    struct dirent *entry;
    char filepath[512]; // 目录下文件路径

    if ((dir = opendir(dir_path)) == NULL){
        perror("打开目录失败");
        return -1;
    }
    // 遍历目录项
    while ((entry = readdir(dir)) != NULL){
        if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0)
            continue;
        snprintf(filepath, sizeof(filepath), "%s/%s", dir_path, entry->d_name);
        // 删除文件
        if (unlink(filepath) == -1){
            perror("删除文件失败");
            closedir(dir);
            return -1;
        }
    }
    closedir(dir);
    if(rmdir(dir_path) == -1) {
        perror("删除目录失败");
        return -1;
    }
    return 0;
}

int drop_table(struct drop_struct *drop_var){
    if(strcmp(pwd, "database") == 0)
        return 3;
    
    int success = 2;
    char table_name[256];
    char line[256];
    char temp_sysdat_path[512];
    char sysdat_path[512];
    snprintf(temp_sysdat_path, sizeof(temp_sysdat_path), "%s%s/temp.dat", root_path, pwd);
    snprintf(sysdat_path, sizeof(sysdat_path), "%s%s/sys.dat", root_path, pwd);
    FILE *new_fp = fopen(temp_sysdat_path, "w");
    FILE *old_fp = fopen(sysdat_path, "r");
    rewind(new_fp);
    rewind(old_fp);
    while(fgets(table_name, sizeof(table_name), old_fp)){
        char *nl = strchr(table_name, '\n');
        if(nl)  *nl = '\0';
        strncpy(line, table_name, sizeof(table_name));
        char *whitespace = strchr(table_name, ' ');
        if (whitespace) *whitespace = '\0';
        if(strcmp(table_name, drop_var->name) == 0){
            success = 1;
            continue;
        }
        else
            fprintf(new_fp, "%s\n", line);
    }
    fclose(old_fp);
    fclose(new_fp);
    // 删除源文件
    if (remove(sysdat_path) != 0) {
        perror("删除原文件出错");
        return -1;
    }
    // 改名新文件
    if (rename(temp_sysdat_path, sysdat_path) != 0) {
        perror("重命名临时文件出错");
        return -1;
    }
    if(success == 1){
        char rm_file_path[512];
        snprintf(rm_file_path, sizeof(rm_file_path), "%s%s/%s.txt", root_path, pwd, drop_var->name);
        if(remove(rm_file_path) != 0){
            perror("删除表文件出错");
            return -1;
        }
    }
    return success;
}

void free_drop_struct(struct drop_struct *drop_var){
    if(!drop_var)   return;
    if(drop_var->name)  free(drop_var->name);
    free(drop_var);
}
/*****************************************************************************/

/*********************************insert**************************************/
int insert_data(struct insert_struct *insert_var){
    if(strcmp(pwd, "database") == 0)
        return 3;

    // 临时存放数据的结构体，用于判断各列数据插入是否正确和保存写入文件前整理好的数据，仅在此函数内使用
    struct tempdata{
        char *column_name;
        char *value;                // 数值和字符串都存储为字符串，最终写入文件
        int index;                  // 元数据序号
        enum DATATYPE type;
        int length;
        struct tempdata *next;
    };

    int success = 2;                // 找到表为1，找不到为2
    char line[256];
    char sysdat_path[512];
    char datafile_path[512];

    snprintf(sysdat_path, sizeof(sysdat_path), "%s%s/sys.dat", root_path, pwd);
    snprintf(datafile_path, sizeof(datafile_path), "%s%s/%s.txt", root_path, pwd, insert_var->table_name);

    FILE *sysdat_fp = fopen(sysdat_path, "r");
    if (!sysdat_fp){
        perror("sys.dat");
        return -1;
    }
    rewind(sysdat_fp);

    struct insert_value *cur_value = insert_var->values;
    struct insert_column *cur_column = insert_var->columns;
    struct tempdata *temp_data = NULL;

    // 读取sys.dat文件生成str_value字段为空，其他不为空的tempdata链表
    while(fgets(line, sizeof(line), sysdat_fp)){
        char *nl = strchr(line, '\n');
        if(nl)  *nl = '\0';
        // 获取每一行的第一个空格前的字符串，即表名
        char *table_name = strtok(line, " ");
        if(strcmp(table_name, insert_var->table_name) != 0)
            continue;
        else{
            success = 1;
            char *tokens[5];                    // 存储一行中的多个字段
            int token_count = 0;
            char *token = strtok(NULL, " ");    // 这次分割后第一项即为元数据序号
            while(token && token_count < 5){
                tokens[token_count++] = token;
                token = strtok(NULL, " ");
            }
            struct tempdata *new_column = (struct tempdata*)malloc(sizeof(struct tempdata));
            new_column->value = NULL;
            new_column->index = atoi(tokens[0]);
            new_column->column_name = tokens[1];
            if(strcmp(tokens[2], "int") == 0){
                new_column->type = INT;
                new_column->length = 0;
            }
            else{
                new_column->type = CHAR;
                new_column->length = atoi(tokens[3]);
            }
            new_column->next = NULL;
            // temp_data链表空，则先将第一个节点挂上
            if(!temp_data){
                temp_data = new_column;
                continue;
            }
            // 不空则在表尾加上
            struct tempdata *last = temp_data;
            while(last->next) last = last->next;
            last->next = new_column;
        }
    }
    fclose(sysdat_fp);
    if(success == 2)    return success;         // 表不存在，直接返回2
    
    // 表存在，开始执行插入操作
    FILE *datafile_fp = fopen(datafile_path, "a+");
    if (!datafile_fp){
        perror("基本数据文件");
        return -1;
    }
    rewind(datafile_fp);
    // 约定：若插入时数据不全，系统会在空缺处记录'*'，表示数据为空
    char *padding = "*";
    if(insert_var->columns){                    
        // 指定列名
        // 将乱序的数据按照sys.dat文件中的顺序插入到.txt.文件中
        // 检测列是否存在、插入数据类型是否匹配、char类型变量是否越界
        return success;
    }
    else{                                       
        // 不指定列名，按照sys.dat文件中的顺序进行插入
        // 检测插入数据类型是否匹配、char类型变量是否越界
        struct tempdata *cur_tempdata = temp_data;
        // 先填写有数据的列
        while(cur_tempdata && cur_value){
            if(cur_tempdata->type == cur_value->type){  // 查类型
                if(cur_tempdata->type == CHAR){
                    int data_length = strlen(cur_value->value);
                    if(data_length > cur_tempdata->length)  // 查长度
                        return 5;
                    cur_tempdata->value = cur_value->value;
                }
                else
                    cur_tempdata->value = cur_value->value;
            }
            else
                return 4;
            cur_tempdata = cur_tempdata->next;
            cur_value = cur_value->next_value;
        }
        // 没有数据的列填写'*'
        while(cur_tempdata){
            cur_tempdata->value = padding;
            cur_tempdata = cur_tempdata->next;
        }
        // 写入文件
        cur_tempdata = temp_data;
        while(cur_tempdata){
            assert(cur_tempdata->value != NULL);
            fprintf(datafile_fp, "%s", cur_tempdata->value);
            if(cur_tempdata->next)  fprintf(datafile_fp, " ");
            else    fprintf(datafile_fp, "\n");
            cur_tempdata = cur_tempdata->next;
        }
    }
    // 释放tempdata，关闭fp
    fclose(datafile_fp);
    while(temp_data){
        struct tempdata *next = temp_data->next;
        free(temp_data);
        temp_data = next;
    }
    return success;
}

void free_insert_struct(struct insert_struct *insert_var){
    if(!insert_var) return;
    if(insert_var->columns){
        while(insert_var->columns){
            struct insert_column *next = insert_var->columns->next_column;
            free(insert_var->columns->name);
            free(insert_var->columns);
            insert_var->columns = next;
        }
    }
    if(insert_var->values){
        while(insert_var->values){
            struct insert_value *next = insert_var->values->next_value;
            free(insert_var->values->value);
            free(insert_var->values);
            insert_var->values = next;
        }
    }
    if(insert_var->table_name)
        free(insert_var->table_name);
    free(insert_var);
}
/*****************************************************************************/