{ wwwRoot }:
{ config, pkgs, ... }:
{
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;

    commonHttpConfig = ''
      log_format json_analytics escape=json '{'
      '"time_local": "$time_local", '
      '"remote_addr": "$remote_addr", '
      '"request_uri": "$request_uri", '
      '"status": "$status", '
      '"http_referer": "$http_referer", '
      '"http_user_agent": "$http_user_agent", '
      '"server_name": "$server_name", '
      '"request_time": "$request_time"'
      '}';
    '';

    virtualHosts."joe.neeman.me" = {
      forceSSL = true;
      enableACME = true;
      root = wwwRoot;
      extraConfig = ''
        access_log /var/log/nginx/analytics.log json_analytics;
      '';
    };

    virtualHosts.${config.services.grafana.settings.server.domain} = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:2342";
        proxyWebsockets = true;
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "joeneeman@gmail.com";
  };


  services.promtail = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = 9080;
        grpc_listen_port = 0;
      };

      positions = {
        filename = "/tmp/positions.yaml";
      };

      clients = [{
        url = "http://localhost:3100/loki/api/v1/push";
      }];

      scrape_configs = [
        {
          job_name = "nginx";
          static_configs = [
            {
              targets = ["localhost"];
              labels = {
                job = "nginx";
                host = "joe.neeman.me";
                agent = "promtail";
                __path__ = "/var/log/nginx/analytics*.log";
              };
            }
          ];

          pipeline_stages = [
            {
              json = {
                expressions = {
                  http_user_agent = "http_user_agent";
                  request_uri = "request_uri";
                  status = "status";
                  request_time = "request_time";
                  http_referer = "http_referer";
                  remote_addr = "remote_addr";
                };
              };
            }
            {
              labels = {
                http_user_agent = null;
                request_uri = null;
                status = null;
                request_time = null;
                http_referer = null;
                remote_addr = null;
              };
            }
          ];
        }
      ];
    };
  };

  services.loki = {
    enable = true;
    configuration = {
      auth_enabled = false;
      server = {
        http_listen_port = 3100;
        grpc_listen_port = 9096;
      };
      common = {
        instance_addr = "127.0.0.1";
        path_prefix = "/tmp/loki";
        storage = {
          filesystem = {
            chunks_directory = "/tmp/loki/chunks";
            rules_directory = "/tmp/loki/rules";
          };
        };
        replication_factor = 1;
        ring = {
          kvstore = { store = "inmemory"; };
        };        
      };
      query_range = {
        results_cache = {
          cache = {
            embedded_cache = {
              enabled = true;
              max_size_mb = 100;
            };
          };
        };
      };
      # TODO: without this, loki complains about the v11 schema below.
      # Maybe once the v13 schema has taken effect we can remove this?
      limits_config = {
        allow_structured_metadata = false;
      };
      schema_config = {
        configs = [
          {
            from = "2020-10-24";
            store = "boltdb-shipper";
            object_store = "filesystem";
            schema = "v11";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }
          {
            from = "2024-07-11";
            store = "tsdb";
            object_store = "filesystem";
            schema = "v13";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }
        ];
      };
      ruler = { alertmanager_url = "http://localhost:9093"; };
      analytics.reporting_enabled = false;
    };
  };

  services.grafana = {
    enable = true;
    settings.server = {
      domain = "grafana.neeman.me";
      http_port = 2342;
      http_addr = "127.0.0.1";
    };
  };
}

