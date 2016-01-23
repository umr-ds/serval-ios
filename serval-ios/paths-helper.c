//
//  paths-helper.c
//  serval-ios
//
//  Created by Jonas Höchst on 21.11.15.
//  Copyright © 2015 Jonas Höchst. All rights reserved.
//

#include "paths-helper.h"
#include <TargetConditionals.h>
#include <stdlib.h>
#include <string.h>

char* sandboxPath(char* localPath){
    char* envHome = getenv("HOME");
    char* path = malloc(strlen(localPath)+strlen(envHome));
    strcpy(path, getenv("HOME"));
    strcat(path, localPath);
    return path;
}
