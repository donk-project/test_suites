def dm2pb(name, environment, srcs):
    native.genrule(
        name = name,
        srcs = srcs + [environment],
        outs = [name + "_output.binarypb"],
        cmd = """
    $(execpath @spacemandmm//src/dm2pb:dm2pb) -e $(rootpath {environment}) -o output.binarypb
    mv output.binarypb $(location {name}_output.binarypb)
    """.format(environment = environment, name = name),
        tools = ["@spacemandmm//src/dm2pb:dm2pb"],
    )

def pb2cc(ctx, dtpo_sources, srcs_zip, dtpo_headers, hdrs_zip):
    cmd_tmpl = (
        "{transpiler} --write_mode {write_mode} \\\n  --project_name {name}_dtpo.{extension} \\\n  --input_proto {input_proto} \\\n  --output_path {name}_dtpo.{extension}\\\n" +
        "   && zip -0 -X -qr {zip_filename} {name}_dtpo.{extension}"
    )
    ctx.actions.run_shell(
        command = cmd_tmpl.format(
            transpiler = ctx.executable._transpiler.path,
            input_proto = ctx.file.input_proto.path,
            write_mode = "sources",
            extension = "cc",
            zip_filename = srcs_zip.path,
            output_dir = dtpo_sources.path,
            name = ctx.label.name,
        ),
        mnemonic = "DmPb2Cc",
        inputs = [ctx.file.input_proto],
        tools = [ctx.executable._transpiler],
        use_default_shell_env = True,
        outputs = [srcs_zip],
    )
    ctx.actions.run_shell(
        command = cmd_tmpl.format(
            transpiler = ctx.executable._transpiler.path,
            input_proto = ctx.file.input_proto.path,
            write_mode = "headers",
            extension = "h",
            output_dir = dtpo_headers.path,
            zip_filename = hdrs_zip.path,
            name = ctx.label.name,
        ),
        mnemonic = "DmPb2Hh",
        inputs = [ctx.file.input_proto],
        tools = [ctx.executable._transpiler],
        use_default_shell_env = True,
        outputs = [hdrs_zip],
    )

def _donk_library_impl(ctx):
    dtpo_sources = ctx.actions.declare_directory(ctx.label.name + "_dtpo.cc")
    dtpo_headers = ctx.actions.declare_directory(ctx.label.name + "_dtpo.h")
    srcs_zip = ctx.actions.declare_file(ctx.label.name + "_dtpo_sources.zip")
    hdrs_zip = ctx.actions.declare_file(ctx.label.name + "_dtpo_headers.zip")
    pb2cc(ctx, dtpo_sources, srcs_zip, dtpo_headers, hdrs_zip)

    cmd_tmpl = "unzip -qq -o {zipfile} -d $(dirname {dtpo_dir})"
    ctx.actions.run_shell(
        command = cmd_tmpl.format(
            zipfile = srcs_zip.path,
            dtpo_dir = dtpo_sources.path,
        ),
        mnemonic = "CcFiles",
        inputs = [srcs_zip],
        outputs = [dtpo_sources],
        use_default_shell_env = True,
    )

    ctx.actions.run_shell(
        command = cmd_tmpl.format(
            zipfile = hdrs_zip.path,
            dtpo_dir = dtpo_headers.path,
        ),
        mnemonic = "HFiles",
        inputs = [hdrs_zip],
        outputs = [dtpo_headers],
        use_default_shell_env = True,
    )

    cc_toolchain = ctx.attr._cc_toolchain[cc_common.CcToolchainInfo]
    if type(cc_toolchain) != "CcToolchainInfo":
        fail("_cc_toolchain not of type CcToolchainInfo. Found: " + type(cc_toolchain))

    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
    )

    includes = depset([dtpo_headers])

    compilation_context, compilation_outputs = cc_common.compile(
        actions = ctx.actions,
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        public_hdrs = [dtpo_headers],
        srcs = [dtpo_sources],
        defines = ["BLYAT"],
        includes = [dtpo_headers.path],
        strip_include_prefix = ctx.label.name + "_dtpo.h",
        name = "%s_link" % ctx.label.name,
    )

    return [
        CcInfo(
            compilation_context = compilation_context,
        ),
        DefaultInfo(files = depset(direct = [dtpo_headers, dtpo_sources])),
    ]

donk_library = rule(
    _donk_library_impl,
    attrs = {
        "input_proto": attr.label(
            allow_single_file = [".binarypb"],
        ),
        "_transpiler": attr.label(
            default = "@donk_transpiler//bazel:transpiler",
            executable = True,
            cfg = "host",
        ),
        "_cc_toolchain": attr.label(
            default = Label("@bazel_tools//tools/cpp:current_cc_toolchain"),
            providers = [cc_common.CcToolchainInfo],
        ),
    },
    output_to_genfiles = True,
    fragments = ["cpp"],
)
