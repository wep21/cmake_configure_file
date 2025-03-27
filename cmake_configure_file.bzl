# Copied from the Drake project:
# https://github.com/RobotLocomotion/drake/blob/17423f8fb6f292b4af0b4cf3c6c0f157273af501/tools/workspace/cmake_configure_file.bzl

def _expand(string, ctx):
    """Expand Make Variables in string.

    Expands $(location ...) templates (https://bazel.build/rules/lib/builtins/ctx.html#expand_location) for targets given in data = [...].
    Replaces $(VAR) with the value of VAR in ctx.var. These are defined by the toolchains = [...] added to the rule.
    Only "$(...)" is expanded, "$$(...)" is ignored.
    """
    expanded = ctx.expand_location(string, ctx.attr.data)
    expanded = expanded.replace("$$", "💰💰")
    for key, val in ctx.var.items():
        expanded = expanded.replace("$(%s)" % key, val)
    expanded = expanded.replace("💰💰", "$$")
    return expanded

# Defines the implementation actions to cmake_configure_file.
def _cmake_configure_file_impl(ctx):
    arguments = ctx.actions.args()
    arguments.add_all(["--input", ctx.file.src.path])
    arguments.add_all(["--output", ctx.outputs.out.path])
    defines = [_expand(define, ctx) for define in ctx.attr.defines]
    arguments.add_all(defines, before_each = "-D")
    undefines = [_expand(undefine, ctx) for undefine in ctx.attr.undefines]
    arguments.add_all(undefines, before_each = "-U")
    arguments.add_all(ctx.files.cmakelists, before_each = "--cmakelists")
    ctx.actions.run(
        inputs = [ctx.file.src] + ctx.files.cmakelists,
        outputs = [ctx.outputs.out],
        arguments = [arguments],
        env = ctx.attr.env,
        executable = ctx.executable.cmake_configure_file_py,
    )
    return []

# Defines the rule to cmake_configure_file.
_cmake_configure_file_gen = rule(
    attrs = {
        "src": attr.label(
            allow_single_file = True,
            mandatory = True,
        ),
        "out": attr.output(mandatory = True),
        "defines": attr.string_list(),
        "undefines": attr.string_list(),
        "cmakelists": attr.label_list(allow_files = True),
        "cmake_configure_file_py": attr.label(
            cfg = "exec",
            executable = True,
            default = Label("//:cmake_configure_file"),
        ),
        "env": attr.string_dict(
            mandatory = True,
            allow_empty = True,
        ),
        "data": attr.label_list(allow_files = True),
    },
    output_to_genfiles = True,
    implementation = _cmake_configure_file_impl,
)

def cmake_configure_file(
        name,
        src = None,
        out = None,
        defines = None,
        undefines = None,
        cmakelists = None,
        **kwargs):
    """Creates a rule to generate an out= file from a src= file, using CMake's
    configure_file substitution semantics.  This implementation is incomplete,
    and may not produce the same result as CMake in all cases.
    Definitions optionally can be passed in directly as defines= strings (with
    the usual defines= convention of either a name-only "HAVE_FOO", or a
    key-value "MYSCALAR=DOUBLE").
    Definitions optionally can be read from simple CMakeLists files that
    contain statements of the form "set(FOO_MAJOR_VERSION 1)" and similar.
    Variables that are known substitutions but which should be undefined can be
    passed as undefines= strings.
    See cmake_configure_file.py for our implementation of the configure_file
    substitution rules.
    The CMake documentation of the configure_file macro is:
    https://cmake.org/cmake/help/latest/command/configure_file.html
    """
    _cmake_configure_file_gen(
        name = name,
        src = src,
        out = out,
        defines = defines,
        undefines = undefines,
        cmakelists = cmakelists,
        env = {},
        **kwargs
    )
