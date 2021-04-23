// Copyright (c) 2020 Cesanta Software Limited
// All rights reserved

#include "mongoose.h"
#include <stdlib.h>

static const char *s_debug_level = "2";
static const char *s_root_dir = ".";
static char s_listening_address[32] = {0};
static const char *s_enable_hexdump = "no";
static char listen_port[7] = {0};
static char cmd_dir[MG_PATH_MAX] = {0};
static char ext_response[1024] = {0};
static char html_root[MG_PATH_MAX] = {0};
static const char* help = "\tCommand server\n\nUsage url: /cmd/<command>    .........  executes \"./cmd/command.cmd\"\nAvailable commands:\n";
static const char cmdExecScript[] = "cmd/cmdexec.sh";

static void shell_op(struct mg_connection *c, char* command)
{
  ext_response[0] = 0;
  LOG(LL_INFO, ("Running: %s", command));
  FILE *fp;
  
  /* Open the command for reading. */
  fp = popen(command, "r");
  if (fp == NULL) {
    printf(ext_response, "Unknown error.");  
  }else{    
    while (fgets(ext_response, sizeof(ext_response), fp) != NULL){
      // printf("\t %s", ext_response);
      char* errorStart = strstr(ext_response, cmdExecScript);
      if(errorStart == NULL){
        mg_http_printf_chunk(c, ext_response); 
      }else{
        errorStart += sizeof(cmdExecScript);
        mg_http_printf_chunk(c, errorStart); 
      }
      
    }
    pclose(fp);
  } 
}

static void cb(struct mg_connection *c, int ev, void *ev_data, void *fn_data) {
  if (ev == MG_EV_HTTP_MSG) {
    struct mg_http_message *hm = (struct mg_http_message *) ev_data;           

    if(mg_http_match_uri(hm, "/cmd/#")){
      char command[MG_PATH_MAX] = {0}; 
      char cmd_name[128] = {0};  
      
      mg_printf(c, "HTTP/1.1 200 OK\r\nTransfer-Encoding: chunked\r\n\r\n");
      snprintf(cmd_name, (int)hm->uri.len, "%.*s\n", (int)hm->uri.len, &hm->uri.ptr[sizeof("/cmd")]);      
     
      char* end = strchr(cmd_name, ' ');
      if(end != NULL){
        end[0] = 0;
      }      

      if(cmd_name[0] == 0){
        // No command specified
        mg_http_printf_chunk(c, "Error: No command specified.\n\n");
        mg_http_printf_chunk(c, help);
        mg_list_commands(c, cmd_dir);

      }else{

        sprintf(command,"%s %s.cmd\n", cmdExecScript, cmd_name);
        shell_op(c, command);
      }      

      mg_http_printf_chunk(c, "");

    }else {
      struct mg_http_serve_opts opts = {html_root, "#.shtml"};
      int retVal = mg_http_serve_dir(c, ev_data, &opts);
      if( retVal != 0){
        mg_printf(c, "HTTP/1.1 200 OK\r\nTransfer-Encoding: chunked\r\n\r\n");
        mg_http_printf_chunk(c, "Error: %d\n\n", retVal);
        mg_http_printf_chunk(c, help);
        mg_list_commands(c, cmd_dir);
        mg_http_printf_chunk(c, "");
      }
    } 
  }
  (void) fn_data;
}

static void usage(const char *prog) {
  fprintf(stderr,
          "Command server\nBased on Mongoose v.%s, built " __DATE__ " " __TIME__
          "\nUsage: %s OPTIONS\n"          
          "  -d DIR        - directory to serve\n"
          "  -p PORT       - optional listening port, default: %s\n",
          MG_VERSION, prog, s_listening_address);
  exit(EXIT_FAILURE);
}

int main(int argc, char *argv[]) {
  struct mg_mgr mgr;
  struct mg_connection *c;
  int i;

  // Set defaults
  strcpy(s_listening_address, "http://0.0.0.0:8000");
  strcpy(listen_port, "8000");

  // Parse command-line flags
  for (i = 1; i < argc; i++) {
    if (strcmp(argv[i], "-d") == 0) {
      s_root_dir = argv[++i];
    } else if (strcmp(argv[i], "-p") == 0) {
      strncpy(listen_port, argv[++i], sizeof(listen_port) - 1);

      strcpy(s_listening_address, "http://0.0.0.0:");
      strcat(s_listening_address, listen_port);
      strcat(s_listening_address, "  ");      
    } else {
      usage(argv[0]);
    }
  }

  // Initialise stuff
  mg_log_set(s_debug_level);
  mg_mgr_init(&mgr);
  if ((c = mg_http_listen(&mgr, s_listening_address, cb, &mgr)) == NULL) {
    LOG(LL_ERROR, ("Cannot listen on %s.", s_listening_address));
    exit(EXIT_FAILURE);
  }
  if (mg_casecmp(s_enable_hexdump, "yes") == 0) c->is_hexdumping = 1;

  // Start infinite event loop
  sprintf(cmd_dir, "%s/cmd/", s_root_dir);
  sprintf(html_root, "%s/web", s_root_dir);  
  chdir(s_root_dir);

  LOG(LL_INFO, ("Starting command server based on Mongoose v%s, serving [%s]", MG_VERSION, s_root_dir));
  for (;;) mg_mgr_poll(&mgr, 1000);
  mg_mgr_free(&mgr);
  return 0;
}
