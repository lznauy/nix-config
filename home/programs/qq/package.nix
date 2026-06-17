# QQNT — 版本锁定
# 腾讯 CDN 下载，固定版本避免上游 hash 变动
{
  qq,
  fetchurl,
}:
qq.overrideAttrs (old: {
  version = "3.2.29-2026-05-28";
  src = fetchurl {
    url = "https://qqdl.gtimg.cn/qqfile/QQNT/9.9.31/release/00e6a3e7/QQ_3.2.29_260528_amd64_01.deb";
    hash = "sha256-HjgoB5ZzyUmUvA9HgNXYUoZHY5kgZZhi1J0cLyoZjiU=";
  };
})
