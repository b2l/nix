{ config, ... }:

{
  home.sessionVariables = {
    POETRY_REPOSITORIES_FURY_URL = "https://pypi.fury.io/lcdp/";
  };

  # Maven + sbt auth for Gemfury. The files carry no secret: they read the
  # GEMFURY_DEPLOY_TOKEN env var (exported in bash from the sops-decrypted blob)
  # at runtime, so they stay non-secret and fully declarative.
  home.file = {
    ".m2/settings.xml".text = ''
      <settings xmlns="http://maven.apache.org/SETTINGS/1.0.0">
        <servers>
          <server>
            <id>lcdp-fury</id>
            <username>''${env.GEMFURY_DEPLOY_TOKEN}</username>
            <password>NOPASS</password>
            <configuration>
              <httpConfiguration>
                <all>
                  <usePreemptive>true</usePreemptive>
                </all>
              </httpConfiguration>
            </configuration>
          </server>
        </servers>
      </settings>
    '';

    # Separate file so it doesn't clobber the existing ~/.sbt/1.0/global.sbt.
    ".sbt/1.0/lcdp-credentials.sbt".text = ''
      credentials += Credentials(
        "Gemfury Realm",
        "maven.fury.io",
        sys.env.getOrElse("GEMFURY_DEPLOY_TOKEN", ""),
        "NOPASS"
      )
    '';
  };

  programs.bash = {
    initExtra = ''
      # lcdp work aliases
      alias dc="cd $PROJ_DIR/lcdp-docker-compose"
      alias front="cd $PROJ_DIR/front"
      alias terraf="cd $PROJ_DIR/terraform"
      alias mono="cd $PROJ_DIR/lcdp-monolith-sve"
      alias lcdp-aws-login='aws ecr get-login-password --profile staging | docker login --password-stdin --username AWS 721041490777.dkr.ecr.us-east-1.amazonaws.com'
      alias lcdp-down='docker compose -p base down --remove-orphans'

      # lcdp docker functions
      lcdp-setup-kafka() {
        cd "$PROJ_DIR/lcdp-docker-compose/base" || return 1
        docker compose --env-file ../.env -f docker-compose.yml -f docker-compose.kafka.yml --profile setup run --rm -it kafka-setup
        echo "Stopping containers..."
        docker compose -p base down
        echo "Kafka setup complete. Topics persisted in volumes."
      }

      _lcdp_collect_up_args() {
        # Fills global arrays __compose_files and __extra_args from "$@"
        __compose_files=(--env-file ../.env -f docker-compose.yml -f docker-compose.kafka.yml)
        __extra_args=()
        [ -f "../.env.local" ] && __compose_files+=(--env-file ../.env.local)
        local arg line
        for arg in "$@"; do
          if [[ "$arg" == -* ]]; then
            __extra_args+=("$arg")
          elif [ -f "../customs/$arg.txt" ]; then
            while IFS= read -r line || [[ -n "$line" ]]; do
              __compose_files+=(-f "overrides/$line")
            done < "../customs/$arg.txt"
          elif [ -f "overrides/$arg.yml" ]; then
            __compose_files+=(-f "overrides/$arg.yml")
          else
            echo "Unknown custom: $arg" >&2
            return 1
          fi
        done
      }

      lcdp-up() {
        cd "$PROJ_DIR/lcdp-docker-compose/base" || return 1
        _lcdp_collect_up_args "$@" || return 1
        echo "docker compose ''${__compose_files[*]} up ''${__extra_args[*]}"
        docker compose "''${__compose_files[@]}" up "''${__extra_args[@]}"
      }

      lcdp-prod() {
        cd "$PROJ_DIR/lcdp-docker-compose/base" || return 1
        local compose_files=(--env-file ../.env -f docker-compose.yml -f docker-compose.kafka.yml -f docker-compose.production.yml)
        local extra_args=()
        [ -f "../.env.local" ] && compose_files+=(--env-file ../.env.local)
        local arg line
        for arg in "$@"; do
          if [[ "$arg" == -* ]]; then
            extra_args+=("$arg")
          elif [ -f "../customs/$arg.txt" ]; then
            while IFS= read -r line || [[ -n "$line" ]]; do
              compose_files+=(-f "overrides/$line")
            done < "../customs/$arg.txt"
          elif [ -f "overrides/$arg.yml" ]; then
            compose_files+=(-f "overrides/$arg.yml")
          else
            echo "Unknown custom: $arg" >&2
            return 1
          fi
        done
        echo "docker compose ''${compose_files[*]} up ''${extra_args[*]}"
        docker compose "''${compose_files[@]}" up "''${extra_args[@]}"
      }

      lcdp-pull() {
        cd "$PROJ_DIR/lcdp-docker-compose/base" || return 1
        local compose_files=(--env-file ../.env -f docker-compose.yml -f docker-compose.kafka.yml)
        local services=()
        [ -f "../.env.local" ] && compose_files+=(--env-file ../.env.local)
        local arg line
        for arg in "$@"; do
          if [ -f "../customs/$arg.txt" ]; then
            while IFS= read -r line; do
              compose_files+=(-f "overrides/$line")
            done < "../customs/$arg.txt"
          elif [ -f "overrides/$arg.yml" ]; then
            compose_files+=(-f "overrides/$arg.yml")
          fi
          case "$arg" in
            monolith)           services+=(monolith_service) ;;
            front)              services+=(front_service) ;;
            af|admin-front)     services+=(admin_front_service) ;;
            maf)                services+=(monolith_service admin_front_service front_service) ;;
          esac
        done
        docker compose "''${compose_files[@]}" pull "''${services[@]}"
      }

      lcdp-kpow-license() {
        echo "export KPOW_CE_LICENSE_ID=$(aws ssm get-parameter --profile staging --name /kpow-ce/license_id --query Parameter.Value --output text)"
        echo "export KPOW_CE_LICENSE_CODE=$(aws ssm get-parameter --profile staging --name /kpow-ce/license_code --query Parameter.Value --output text)"
        echo "export KPOW_CE_LICENSEE=$(aws ssm get-parameter --profile staging --name /kpow-ce/licensee --query Parameter.Value --output text)"
        echo "export KPOW_CE_LICENSE_EXPIRY=$(aws ssm get-parameter --profile staging --name /kpow-ce/license_expiry --query Parameter.Value --output text)"
        echo "export KPOW_CE_LICENSE_SIGNATURE=$(aws ssm get-parameter --profile staging --name /kpow-ce/license_signature --query Parameter.Value --output text)"
      }

      # source lcdp env (decrypted by sops-nix at activation)
      [ -f "${config.sops.secrets."lcdp_env".path}" ] && . "${config.sops.secrets."lcdp_env".path}"

      # map the Gemfury deploy token to poetry/uv auth (token = username, blank password)
      if [ -n "$GEMFURY_DEPLOY_TOKEN" ]; then
        export POETRY_HTTP_BASIC_FURY_USERNAME="$GEMFURY_DEPLOY_TOKEN"
        export POETRY_HTTP_BASIC_FURY_PASSWORD=""
        export UV_INDEX_FURY_USERNAME="$GEMFURY_DEPLOY_TOKEN"
        export UV_INDEX_FURY_PASSWORD=""
      fi
    '';
  };
}
