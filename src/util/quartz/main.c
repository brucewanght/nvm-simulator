#include <argp.h>
#include <assert.h>
#include <errno.h>
#include <fcntl.h>
#include <inttypes.h>
#include <math.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <attr/xattr.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/mman.h>

void cmd_make(struct argp_state* state);

const char *argp_program_version = "x, version 0.1";
const char *argp_program_bug_address = "haris.volos@hpe.com";
error_t argp_err_exit_status = 1;

struct arg_global
{
    int verbosity;
    int seed;
};

static struct argp_option opt_global[] =
{
/* { name, key, arg-name, flags,
 *      doc, group } */

    { "verbose", 'v', "level", OPTION_ARG_OPTIONAL,
          "Increase or set the verbosity level.", -1},

    { "quiet", 'q', 0, 0,
          "Set verbosity to 0.", -1},

    // make -h an alias for --help
    { 0 }
};

static char doc_global[] =
  "\n"
  "Manage Quartz."
  "\v"
  "Supported commands are:\n"
  "  make    Create emulation topology.\n"
  ;

static error_t
parse_global(int key, char* arg, struct argp_state* state)
{
    struct arg_global* global = state->input;

    switch(key)
    {
        case 'v':
            if(arg)
                global->verbosity = atoi(arg);
            else
                global->verbosity++;
            break;

        case 'q':
            global->verbosity = 0;
            break;

        case ARGP_KEY_ARG:
            assert( arg );
            if(strcmp(arg, "make") == 0) {
                cmd_make(state);
            } else {
                argp_error(state, "%s is not a valid command", arg);
            }
            break;

        default:
            return ARGP_ERR_UNKNOWN;
  }

  return 0;
}

static struct argp argp_global =
{
    opt_global,
    parse_global,
    "[<cmd> [CMD-OPTIONS]]...",
    doc_global,
};

void cmd_global(int argc, char**argv)
{
    struct arg_global global =
    {
        1, /* default verbosity */
    };

    argp_parse(&argp_global, argc, argv, ARGP_IN_ORDER, NULL, &global);
}

int main(int argc, char *argv[]) {
    cmd_global(argc, argv);
    return 0;
}