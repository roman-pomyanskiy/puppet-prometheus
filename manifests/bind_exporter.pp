# @summary This module manages prometheus node consul_exporter
# @param arch
#  Architecture (amd64 or i386)
# @param download_extension
#  Extension for the release binary archive
# @param download_url
#  Complete URL corresponding to the where the release binary archive can be downloaded
# @param install_method
#  Installation method: url or package
# @param listen_address
#  Address to listen on for web interface and telemetry. (default ":9119")
# @param os
#  Operating system (linux is the only one supported)
# @param package_name
#  The binary package name - not available yet
# @param pid_file
#  Path to Bind's pid file to export process information. (default "/run/named/named.pid")
# @param stats_groups
#  Comma-separated list of statistics to collect. Available: [server, view, tasks] (default "server,view,tasks")
# @param stats_url
#  HTTP XML API address of an Bind server. (default "http://localhost:8053/")
# @param stats_version
#  BIND statistics version. Can be detected automatically. Available: [xml.v2, xml.v3, auto] (default "auto")
# @param telemetry_path
#  Path under which to expose metrics. (default "/metrics")
# @param timeout
#  Timeout for trying to get stats from Bind. (default 10s)
class prometheus::bind_exporter (
  String $download_extension,
  String $download_url_base,
  Array  $extra_groups,
  String $group,
  String $package_ensure,
  String $package_name,
  String $pid_file,
  String $stats_groups,
  String $stats_url,
  String $stats_version,
  String $telemetry_path,
  String $timeout,
  Strung $version,
  String $user,
  String[1] $arch                         = $prometheus::real_arch,
  String $bin_dir                         = $prometheus::bin_dir,
  Optional[String] $download_url          = undef,
  Boolean $export_scrape_job              = false,
  Prometheus::Initstyle $init_style       = $facts['service_provider'],
  String $install_method                  = 'url',
  Boolean $manage_group                   = true,
  Boolean $manage_service                 = true,
  Boolean $manage_user                    = true,
  String[1] $os                           = downcase($facts['kernel']),
  Boolean $purge_config_dir               = true,
  Boolean $restart_on_change              = true,
  Stdlib::Port $scrape_port               = 9119,
  String[1] $scrape_job_name              = 'bind',
  Optional[Hash] $scrape_job_labels       = undef,
  Boolean $service_enable                 = true,
  Stdlib::Ensure::Service $service_ensure = 'running',
){
  $real_download_url = pick($download_url,"${download_url_base}/download/v${version}/${package_name}-${version}.${os}-${arch}.${download_extension}") # lint:ignore:140chars
  $options = "-bind.pid-file=${pid_file} -bind.stats-groups=${stats_groups} -bind.stats-url=${stats_url} -bind.stats-version=${stats_version} -bind.timeout=${timeout} -web.listen-address=:${scrape_port} -web.telemetry-path=${telemetry_path}" # lint:ignore:140chars

  $notify_service = $restart_on_change ? {
    true    => Service['bind_exporter'],
    default => undef,
  }

  prometheus::daemon { 'bind_exporter':
    install_method     => $install_method,
    version            => $version,
    download_extension => $download_extension,
    os                 => $os,
    arch               => $arch,
    real_download_url  => $real_download_url,
    bin_dir            => $bin_dir,
    notify_service     => $notify_service,
    package_name       => $package_name,
    package_ensure     => $package_ensure,
    manage_user        => $manage_user,
    user               => $user,
    extra_groups       => $extra_groups,
    group              => $group,
    manage_group       => $manage_group,
    purge              => $purge_config_dir,
    options            => $options,
    init_style         => $init_style,
    service_ensure     => $service_ensure,
    service_enable     => $service_enable,
    manage_service     => $manage_service,
    export_scrape_job  => $export_scrape_job,
    scrape_port        => $scrape_port,
    scrape_job_name    => $scrape_job_name,
    scrape_job_labels  => $scrape_job_labels,
  }
}
