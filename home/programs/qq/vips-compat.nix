# vips-compat — 为 QQ 预编译的 .node 模块提供新版 libvips 已移除的符号
# 每次 QQ 启动报 undefined symbol 时，在这里添加对应函数即可
{
  stdenv,
  glib,
  vips,
  pkg-config,
}:
let
  cSource = builtins.toFile "vips-compat.c" ''
    #include <glib.h>
    #include <glib-object.h>
    #include <vips/vips.h>
    #include <stdio.h>

    // —— 以下为 libvips 8.15+ 移除的 vips_g_* GLib 包装函数 ——

    void
    vips_g_assert(gboolean expr)
    {
        g_assert(expr);
    }

    gboolean
    vips_g_atomic_int_dec_and_test(gint *atomic)
    {
        return g_atomic_int_dec_and_test(atomic);
    }

    void
    vips_g_atomic_int_inc(gint *atomic)
    {
        g_atomic_int_inc(atomic);
    }

    void
    vips_g_free(gpointer mem)
    {
        g_free(mem);
    }

    guint
    vips_g_log_set_handler(const gchar *log_domain,
                           GLogLevelFlags log_levels,
                           GLogFunc log_func,
                           gpointer user_data)
    {
        return g_log_set_handler(log_domain, log_levels, log_func, user_data);
    }

    gpointer
    vips_g_malloc(gsize size)
    {
        return g_malloc(size);
    }

    gpointer
    vips_g_object_ref(gpointer object)
    {
        return g_object_ref(object);
    }

    void
    vips_g_object_unref(gpointer object)
    {
        g_object_unref(object);
    }

    gpointer
    vips_g_once(void *once, GThreadFunc func, gpointer arg)
    {
        GOnce *g_once = (GOnce *)once;

        if (g_once_init_enter((gsize *)g_once)) {
            g_once->retval = func(arg);
            g_once_init_leave((gsize *)g_once, 1);
        }

        return g_once->retval;
    }

    gulong
    vips_g_signal_connect(gpointer instance,
                          const gchar *detailed_signal,
                          GCallback c_handler,
                          gpointer data)
    {
        return g_signal_connect_data(instance, detailed_signal,
                                     c_handler, data, NULL, 0);
    }

    gint
    vips_g_snprintf(gchar *string, gulong n, gchar const *format, ...)
    {
        va_list args;
        gint result;

        va_start(args, format);
        result = g_vsnprintf(string, n, format, args);
        va_end(args);

        return result;
    }

    // —— 新版 libvips 移除的其他符号 ——

    gboolean
    vips_is_object(gpointer object)
    {
        return VIPS_IS_OBJECT(object);
    }
  '';
in
stdenv.mkDerivation {
  pname = "vips-compat";
  version = "0.3.0";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ glib vips ];

  dontUnpack = true;

  buildPhase = ''
    $CC -shared -fPIC -o libvips-compat.so \
      ${cSource} \
      $(pkg-config --cflags --libs glib-2.0) \
      $(pkg-config --cflags --libs gobject-2.0) \
      $(pkg-config --cflags --libs vips)
  '';

  installPhase = ''
    mkdir -p $out/lib
    cp libvips-compat.so $out/lib/
  '';
}
