#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define MAXINT 2000000000
int GoDeeper();
int GoHigher();
int Search(char*);
int UpdateVarTable( int, char*, char*, int, char*);
int UpdateFctTable();
void ConstructArgumentList (char*);
int CheckIntInit(char*);
int CheckStringInit(char*);
char* GetStringVal(char*);
int GetIntVal(char*);
int UpdateVar(char*, char*);
int UpdateInt(char*,int);
void ConstructSignature(char*);
void PrintTable();
int FindAndUpdateFuncMember(char*, int);
int FindFuncMember(char*);
void CheckFunctionCall(char*);
char* myStrcat(char* dest, const char* src);
struct Table{

    int blockDepth;
    int blockNr;
    int scope;
    char symbol_type[50];
    char symbol_name[50];
    char stringValue[200];
    int Value;

}table[100];

char fsignature[300], argumentList[100], signature[200][500];
int blockNrForDepth[100], curentDepth=1, functionCounter=0,  variableCounter=0;


int GoDeeper()
{
    blockNrForDepth[curentDepth]++;
    curentDepth++;
    return 0;
}

int GoHigher()
{
    curentDepth--;
    return 0;
}

int Search(char* name)
{
    int i;
    int lookupBlockNr = blockNrForDepth[curentDepth-1];
    int lookupDepth = curentDepth;

    for(i = variableCounter-1; i>=0; i--)
    {
        if(table[i].blockDepth < lookupDepth)
        {
            lookupDepth = table[i].blockDepth;
            lookupBlockNr = table[i].blockNr;

        }
        else  if(  table[i].blockDepth == lookupDepth &&
                   table[i].blockNr == lookupBlockNr &&
                   strcmp(table[i].symbol_name, name) == 0 )
        {

            return i;

        }
    }

    return -1;
}

int UpdateVarTable( int scope, char* type, char* id, int Val, char *stringVal)
{
    if(Search(id) != -1 )
    {
        printf("Error: Variable %s %s already declared.\n", type, id);
        return 0;
    }

    strcpy(table[variableCounter].symbol_type, type);
    strcpy(table[variableCounter].symbol_name, id);
    table[variableCounter].blockDepth = curentDepth;
    table[variableCounter].blockNr = blockNrForDepth[curentDepth-1];
    strcpy(table[variableCounter].stringValue, stringVal);
    table[variableCounter].scope = scope;

    table[variableCounter].Value = Val;

    variableCounter++;
    return 0;
}

int CheckIntInit(char* id)
{
    int idIndex;
    if( (idIndex = Search(id)) == -1 )
    {
        printf("Error: variable %s was not declared\n", id);
        return -1;
    }

    if(strcmp(table[idIndex].symbol_type,"int") != 0){
        printf("Error: %s is not of type int\n", id);
        return -1;
    }
    if(table[idIndex].Value == MAXINT )
    {
        printf("Error: %s was not initialized\n", id);
        return -1;
    }
    return 0;
}

int CheckStringInit(char* id){
    int idIndex;
    if( (idIndex = Search(id)) == -1 )
    {
        printf("Error: variable %s was not declared\n", id);
        return -1;
    }
    if(strcmp(table[idIndex].symbol_type,"string") != 0){
        printf("Error: %s is not of type string\n", id);
        return -1;
    }
    
    if(strcmp(table[idIndex].stringValue,"not_a_string") == 0)
    {
        printf("Error: %s was not initialized\n", id);
        return -1;
    }
    return 0;
}

int GetIntVal(char* dest){
    int destIndex;

    if ( (destIndex = Search(dest))== -1)
    {
        printf("Error: variable %s was not declared\n", dest);
        return -1;
    }

    return table[destIndex].Value;
}

char* GetStringVal(char* dest){
    int destIndex;

    if ( (destIndex = Search(dest))== -1)
    {
        printf("Error: variable %s was not declared\n", dest);
        return "\0";
    }

    return table[destIndex].stringValue;
}

int UpdateInt(char* dest, int source)
{
    int destIndex;

    if ( (destIndex = Search(dest))== -1)
    {
        printf("Error: variable %s was not declared\n", dest);
        return -1;
    }

    table[destIndex].Value = source;

    return 0;
}

int UpdateVar(char* dest, char* source)
{
    int sourceIndex, destIndex;

    if ( (sourceIndex = Search(source))== -1)
    {
        printf("Error: variable %s was not declared\n", source);
        return -1;
    }

    if ( (destIndex = Search(dest))== -1)
    {
        printf("Error: variable %s was not declared\n", dest);
        return -1;
    }

    if(strcmp(table[sourceIndex].symbol_type,"int") == 0 )
    {
        if(table[sourceIndex].Value == MAXINT )
        {
            printf("Error: %s was not initialized\n", source);
            return -1;
        }
        table[destIndex].Value = table[sourceIndex].Value;
    }
    else if(strcmp(table[sourceIndex].symbol_type,"string") == 0 )
    {
        if(strcmp(table[sourceIndex].stringValue,"not_a_string") == 0)
        {
            printf("Error: %s was not initialized\n", source);
            return -1;
        }
        strcpy(table[destIndex].stringValue,table[sourceIndex].stringValue);
    }
    else{printf("Error: %s is not a int or string\n", source); return -1;}

    return 0;
}

int UpdateString(char* dest, char*source){
    int destIndex;

    if ( (destIndex = Search(dest))== -1)
    {
        printf("Error: variable %s was not declared\n", dest);
        return -1;
    }
    
    strcpy(table[destIndex].stringValue, source);
    return 0;
}

int UpdateChar(char* dest, char* source){
    int destIndex;

    if ( (destIndex = Search(dest))== -1)
    {
        printf("Error: variable %s was not declared\n", dest);
        return -1;
    }
    
    strcpy(table[destIndex].stringValue, source);
    return 0;
}

int UpdateBool(char*dest, char* source){
    int destIndex;

    if ( (destIndex = Search(dest))== -1)
    {
        printf("Error: variable %s was not declared\n", dest);
        return -1;
    }
    
    if(strcmp(source,"true") == 0)
        table[destIndex].Value = 1;
    else
        table[destIndex].Value = 0;

    return 0;
}

char* myStrcat(char* dest, const char* src)
{
    char* fin=malloc(sizeof(char)*(strlen(dest)+strlen(src)+1));
    bzero(fin,strlen(dest)+strlen(src)+1);
    strcpy(fin,dest);
    strcat(fin,src);
    free(dest);
    dest=strdup(fin);
    free(fin);
    return dest;
}

void PrintTable()
{
    int i;
    int j;
    FILE* f = fopen("symbol_table.txt", "w");
    fprintf(f, "Declared variables: \n");
    for(i=0; i < variableCounter; i++)
    {
        for(j =  table[i].blockDepth; j>1; j--)
        {
            fprintf(f,"\t");
        }


        if (strstr(table[i].symbol_type, "int") != NULL && table[i].Value != 2000000000)
            fprintf(f, "%s %s %d, ", table[i].symbol_type, table[i].symbol_name, table[i].Value);

        else if((strstr(table[i].symbol_type, "char") != NULL || strstr(table[i].symbol_type, "string") != NULL || strstr(table[i].symbol_type, "bool") != NULL) && strcmp(table[i].stringValue, "not_a_string") != 0)
            fprintf(f, "%s %s %s, ", table[i].symbol_type, table[i].symbol_name, table[i].stringValue);
        else
            fprintf(f, "%s %s, ", table[i].symbol_type, table[i].symbol_name);

        if(table[i].scope == 1)
            fprintf(f,"declared in function\n");
        else if(table[i].scope == -1)
            fprintf(f, "declared global\n");
        else
            fprintf(f,"declared in class\n");
    }
    fprintf(f, "\n");
    fprintf(f, "Declared functions: \n");
    for(i=0; i < functionCounter; i++)
    {+
                fprintf(f,"%s\n", signature[i]);

    }
    fclose(f);
}

int SearchFct(char* sign)
{
    for(int i = functionCounter-1; i >=0; i--)
    {

        if(strcmp(signature[i],sign ) == 0 )
        {
            return 1;
        }
    }
    return 0;
}

int UpdateFctTable()
{
    char func[200];
    strcpy(func,fsignature);
    strcat(func,argumentList);
    if(SearchFct(func) == 1 )
    {
        printf("Error: function with signature %s was already declared.\n",fsignature);
        memset(func,0,200);
        memset(fsignature, 0, 300);
        memset(argumentList,0,100);
        return 0;
    }

    strcpy(signature[functionCounter], fsignature);
    strcat(signature[functionCounter],argumentList);
    functionCounter++;
    memset(fsignature, 0, 300);
    memset(argumentList,0,100);
    memset(func,0,200);
}
void ConstructArgumentList(char* argument)
{

    strcat(argumentList, argument);
    strcat(argumentList, " ");

}

void ConstructSignature (char* sig)
{

    strcat(fsignature, sig);
    strcat(fsignature, " ");

}


int FindAndUpdateFuncMember(char *id, int val){
    int i;
    if((i=Search(id)) != -1)
    {
        UpdateInt(id, val);
        return table[i].Value ;

    }
    else {
        printf("Error: Variable %s not declared\n", id);
        exit(1);
    }
}

int FindFuncMember(char *id){
    int i;
    if((i=Search(id)) != -1)
    {
        return table[i].Value;
    }
    else
    {
        printf("Error: Variable %s not declared\n", id);
        exit(1);
    }

}

void CheckFunctionCall(char *id)
{
    for(int i = 0; i <functionCounter; i++)
    {

        if(strstr(signature[i],id ) !=NULL )
        {
            return;
        }
    }
    printf("Error: Function with id: %s was not declared\n", id);
}
