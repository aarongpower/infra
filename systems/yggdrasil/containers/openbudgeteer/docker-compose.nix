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
  virtualisation.oci-containers.containers."openbudgeteer" = {
    image = "axelander/openbudgeteer";
    environment = {
      "APPSETTINGS_CULTURE" = "en-US";
      "APPSETTINGS_THEME" = "solar";
      "CONNECTION_DATABASE" = "openbudgeteer";
      "CONNECTION_PASSWORD" = "openbudgeteer";
      "CONNECTION_PORT" = "3306";
      "CONNECTION_PROVIDER" = "mariadb";
      "CONNECTION_ROOT_PASSWORD" = "myRootPassword";
      "CONNECTION_SERVER" = "openbudgeteer-mariadb";
      "CONNECTION_USER" = "openbudgeteer";
    };
    ports = [
      "18081:8080/tcp"
    ];
    dependsOn = [
      "openbudgeteer-mariadb"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=openbudgeteer"
      "--network=openbudgeteer_default"
    ];
  };
  systemd.services."podman-openbudgeteer" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "no";
    };
    after = [
      "podman-network-openbudgeteer_default.service"
    ];
    requires = [
      "podman-network-openbudgeteer_default.service"
    ];
    partOf = [
      "podman-compose-openbudgeteer-root.target"
    ];
    wantedBy = [
      "podman-compose-openbudgeteer-root.target"
    ];
  };
  virtualisation.oci-containers.containers."openbudgeteer-api" = {
    image = "axelander/openbudgeteer-api";
    environment = {
      "CONNECTION_DATABASE" = "openbudgeteer";
      "CONNECTION_PASSWORD" = "openbudgeteer";
      "CONNECTION_PORT" = "3306";
      "CONNECTION_PROVIDER" = "mariadb";
      "CONNECTION_SERVER" = "openbudgeteer-mariadb";
      "CONNECTION_USER" = "openbudgeteer";
    };
    ports = [
      "18082:8080/tcp"
    ];
    dependsOn = [
      "openbudgeteer-mariadb"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=openbudgeteer-api"
      "--network=openbudgeteer_default"
    ];
  };
  systemd.services."podman-openbudgeteer-api" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "no";
    };
    after = [
      "podman-network-openbudgeteer_default.service"
    ];
    requires = [
      "podman-network-openbudgeteer_default.service"
    ];
    partOf = [
      "podman-compose-openbudgeteer-root.target"
    ];
    wantedBy = [
      "podman-compose-openbudgeteer-root.target"
    ];
  };
  virtualisation.oci-containers.containers."openbudgeteer-mariadb" = {
    image = "mariadb";
    environment = {
      "MYSQL_ROOT_PASSWORD" = "myRootPassword";
    };
    volumes = [
      "openbudgeteer_data:/var/lib/mysql:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=mariadb"
      "--network=openbudgeteer_default"
    ];
  };
  systemd.services."podman-openbudgeteer-mariadb" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "no";
    };
    after = [
      "podman-network-openbudgeteer_default.service"
      "podman-volume-openbudgeteer_data.service"
    ];
    requires = [
      "podman-network-openbudgeteer_default.service"
      "podman-volume-openbudgeteer_data.service"
    ];
    partOf = [
      "podman-compose-openbudgeteer-root.target"
    ];
    wantedBy = [
      "podman-compose-openbudgeteer-root.target"
    ];
  };
  virtualisation.oci-containers.containers."openbudgeteer-phpmyadmin" = {
    image = "phpmyadmin/phpmyadmin";
    ports = [
      "18080:80/tcp"
    ];
    dependsOn = [
      "openbudgeteer-mariadb"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=phpmyadmin"
      "--network=openbudgeteer_default"
    ];
  };
  systemd.services."podman-openbudgeteer-phpmyadmin" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "no";
    };
    after = [
      "podman-network-openbudgeteer_default.service"
    ];
    requires = [
      "podman-network-openbudgeteer_default.service"
    ];
    partOf = [
      "podman-compose-openbudgeteer-root.target"
    ];
    wantedBy = [
      "podman-compose-openbudgeteer-root.target"
    ];
  };

  # Networks
  systemd.services."podman-network-openbudgeteer_default" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f openbudgeteer_default";
    };
    script = ''
      podman network inspect openbudgeteer_default || podman network create openbudgeteer_default
    '';
    partOf = [ "podman-compose-openbudgeteer-root.target" ];
    wantedBy = [ "podman-compose-openbudgeteer-root.target" ];
  };

  # Volumes
  systemd.services."podman-volume-openbudgeteer_data" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect openbudgeteer_data || podman volume create openbudgeteer_data --driver=local --opt=device=/tank/containers/openbudgeteer/db --opt=o=bind --opt=type=none
    '';
    partOf = [ "podman-compose-openbudgeteer-root.target" ];
    wantedBy = [ "podman-compose-openbudgeteer-root.target" ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-openbudgeteer-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
