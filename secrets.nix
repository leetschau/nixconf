let
  leo = "age1xksnj3nxxzqpd4rdzen3ckft2xwjmffvsyljrxx445lv3vneva5sqhjgdq";
in {
  "secrets/rclone.conf.age".publicKeys = [ leo ];
  "secrets/pet-config.age".publicKeys = [ leo ];
  "secrets/glm-api-key.age".publicKeys = [ leo ];
}
