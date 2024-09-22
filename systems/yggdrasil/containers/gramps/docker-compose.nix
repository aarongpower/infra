# Auto-generated using compose2nix v0.2.3-pre.
{ pkgs, lib, ... }:

{
  # Runtime
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
    defaultNetwork.settings = {
      # Required for container networking to be able to use names.
      dns_enabled = true;
    };
  };
  virtualisation.oci-containers.backend = "podman";

  # Containers
  virtualisation.oci-containers.containers."gramps-grampsweb" = {
    image = "ghcr.io/gramps-project/grampsweb:latest";
    environment = {
      "GRAMPSWEB_CELERY_CONFIG__broker_url" = "redis://grampsweb_redis:6379/0";
      "GRAMPSWEB_CELERY_CONFIG__result_backend" = "redis://grampsweb_redis:6379/0";
      "GRAMPSWEB_RATELIMIT_STORAGE_URI" = "redis://grampsweb_redis:6379/1";
      "GRAMPSWEB_TREE" = "Gramps Web";
    };
    volumes = [
      "gramps_gramps_cache:/app/cache:rw"
      "gramps_gramps_db:/root/.gramps/grampsdb:rw"
      "gramps_gramps_index:/app/indexdir:rw"
      "gramps_gramps_media:/app/media:rw"
      "gramps_gramps_secret:/app/secret:rw"
      "gramps_gramps_thumb_cache:/app/thumbnail_cache:rw"
      "gramps_gramps_tmp:/tmp:rw"
      "gramps_gramps_users:/app/users:rw"
    ];
    ports = [
      "8888:5000/tcp"
    ];
    dependsOn = [
      "grampsweb_redis"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=grampsweb"
      "--network=gramps_default"
    ];
  };
  systemd.services."podman-gramps-grampsweb" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-gramps_default.service"
      "podman-volume-gramps_gramps_cache.service"
      "podman-volume-gramps_gramps_db.service"
      "podman-volume-gramps_gramps_index.service"
      "podman-volume-gramps_gramps_media.service"
      "podman-volume-gramps_gramps_secret.service"
      "podman-volume-gramps_gramps_thumb_cache.service"
      "podman-volume-gramps_gramps_tmp.service"
      "podman-volume-gramps_gramps_users.service"
    ];
    requires = [
      "podman-network-gramps_default.service"
      "podman-volume-gramps_gramps_cache.service"
      "podman-volume-gramps_gramps_db.service"
      "podman-volume-gramps_gramps_index.service"
      "podman-volume-gramps_gramps_media.service"
      "podman-volume-gramps_gramps_secret.service"
      "podman-volume-gramps_gramps_thumb_cache.service"
      "podman-volume-gramps_gramps_tmp.service"
      "podman-volume-gramps_gramps_users.service"
    ];
    partOf = [
      "podman-compose-gramps-root.target"
    ];
    wantedBy = [
      "podman-compose-gramps-root.target"
    ];
  };
  virtualisation.oci-containers.containers."gramps-grampsweb_celery" = {
    image = "ghcr.io/gramps-project/grampsweb:latest";
    environment = {
      "GRAMPSWEB_CELERY_CONFIG__broker_url" = "redis://grampsweb_redis:6379/0";
      "GRAMPSWEB_CELERY_CONFIG__result_backend" = "redis://grampsweb_redis:6379/0";
      "GRAMPSWEB_RATELIMIT_STORAGE_URI" = "redis://grampsweb_redis:6379/1";
      "GRAMPSWEB_TREE" = "Gramps Web";
    };
    volumes = [
      "gramps_gramps_cache:/app/cache:rw"
      "gramps_gramps_db:/root/.gramps/grampsdb:rw"
      "gramps_gramps_index:/app/indexdir:rw"
      "gramps_gramps_media:/app/media:rw"
      "gramps_gramps_secret:/app/secret:rw"
      "gramps_gramps_thumb_cache:/app/thumbnail_cache:rw"
      "gramps_gramps_tmp:/tmp:rw"
      "gramps_gramps_users:/app/users:rw"
    ];
    cmd = [ "celery" "-A" "gramps_webapi.celery" "worker" "--loglevel=INFO" ];
    dependsOn = [
      "grampsweb_redis"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=grampsweb_celery"
      "--network=gramps_default"
    ];
  };
  systemd.services."podman-gramps-grampsweb_celery" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-gramps_default.service"
      "podman-volume-gramps_gramps_cache.service"
      "podman-volume-gramps_gramps_db.service"
      "podman-volume-gramps_gramps_index.service"
      "podman-volume-gramps_gramps_media.service"
      "podman-volume-gramps_gramps_secret.service"
      "podman-volume-gramps_gramps_thumb_cache.service"
      "podman-volume-gramps_gramps_tmp.service"
      "podman-volume-gramps_gramps_users.service"
    ];
    requires = [
      "podman-network-gramps_default.service"
      "podman-volume-gramps_gramps_cache.service"
      "podman-volume-gramps_gramps_db.service"
      "podman-volume-gramps_gramps_index.service"
      "podman-volume-gramps_gramps_media.service"
      "podman-volume-gramps_gramps_secret.service"
      "podman-volume-gramps_gramps_thumb_cache.service"
      "podman-volume-gramps_gramps_tmp.service"
      "podman-volume-gramps_gramps_users.service"
    ];
    partOf = [
      "podman-compose-gramps-root.target"
    ];
    wantedBy = [
      "podman-compose-gramps-root.target"
    ];
  };
  virtualisation.oci-containers.containers."grampsweb_redis" = {
    image = "docker.io/library/redis:7.2.4-alpine";
    log-driver = "journald";
    extraOptions = [
      "--network-alias=grampsweb_redis"
      "--network=gramps_default"
    ];
  };
  systemd.services."podman-grampsweb_redis" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-gramps_default.service"
    ];
    requires = [
      "podman-network-gramps_default.service"
    ];
    partOf = [
      "podman-compose-gramps-root.target"
    ];
    wantedBy = [
      "podman-compose-gramps-root.target"
    ];
  };

  # Networks
  systemd.services."podman-network-gramps_default" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f gramps_default";
    };
    script = ''
      podman network inspect gramps_default || podman network create gramps_default
    '';
    partOf = [ "podman-compose-gramps-root.target" ];
    wantedBy = [ "podman-compose-gramps-root.target" ];
  };

  # Volumes
  systemd.services."podman-volume-gramps_gramps_cache" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect gramps_gramps_cache || podman volume create gramps_gramps_cache --driver=local --opt=device=/tank/containers/gramps/cache --opt=o=bind --opt=type=none
    '';
    partOf = [ "podman-compose-gramps-root.target" ];
    wantedBy = [ "podman-compose-gramps-root.target" ];
  };
  systemd.services."podman-volume-gramps_gramps_db" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect gramps_gramps_db || podman volume create gramps_gramps_db --driver=local --opt=device=/tank/containers/gramps/db --opt=o=bind --opt=type=none
    '';
    partOf = [ "podman-compose-gramps-root.target" ];
    wantedBy = [ "podman-compose-gramps-root.target" ];
  };
  systemd.services."podman-volume-gramps_gramps_index" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect gramps_gramps_index || podman volume create gramps_gramps_index --driver=local --opt=device=/tank/containers/gramps/index --opt=o=bind --opt=type=none
    '';
    partOf = [ "podman-compose-gramps-root.target" ];
    wantedBy = [ "podman-compose-gramps-root.target" ];
  };
  systemd.services."podman-volume-gramps_gramps_media" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect gramps_gramps_media || podman volume create gramps_gramps_media --driver=local --opt=device=/tank/containers/gramps/media --opt=o=bind --opt=type=none
    '';
    partOf = [ "podman-compose-gramps-root.target" ];
    wantedBy = [ "podman-compose-gramps-root.target" ];
  };
  systemd.services."podman-volume-gramps_gramps_secret" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect gramps_gramps_secret || podman volume create gramps_gramps_secret --driver=local --opt=device=/tank/containers/gramps/secret --opt=o=bind --opt=type=none
    '';
    partOf = [ "podman-compose-gramps-root.target" ];
    wantedBy = [ "podman-compose-gramps-root.target" ];
  };
  systemd.services."podman-volume-gramps_gramps_thumb_cache" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect gramps_gramps_thumb_cache || podman volume create gramps_gramps_thumb_cache --driver=local --opt=device=/tank/containers/gramps/thumb_cache --opt=o=bind --opt=type=none
    '';
    partOf = [ "podman-compose-gramps-root.target" ];
    wantedBy = [ "podman-compose-gramps-root.target" ];
  };
  systemd.services."podman-volume-gramps_gramps_tmp" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect gramps_gramps_tmp || podman volume create gramps_gramps_tmp --driver=local --opt=device=/tank/containers/gramps/tmp --opt=o=bind --opt=type=none
    '';
    partOf = [ "podman-compose-gramps-root.target" ];
    wantedBy = [ "podman-compose-gramps-root.target" ];
  };
  systemd.services."podman-volume-gramps_gramps_users" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect gramps_gramps_users || podman volume create gramps_gramps_users --driver=local --opt=device=/tank/containers/gramps/users --opt=o=bind --opt=type=none
    '';
    partOf = [ "podman-compose-gramps-root.target" ];
    wantedBy = [ "podman-compose-gramps-root.target" ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-gramps-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
