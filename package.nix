{
  buildGoModule,
  lib,
  installShellFiles,
}:

buildGoModule {
  pname = "systemctl-toggle";
  version = "0.1.0";

  src = ./.;

  vendorHash = "sha256-7K17JaXFsjf163g5PXCb5ng2gYdotnZ2IDKk8KFjNj0=";

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    installShellCompletion --cmd systemctl-toggle \
      --bash <($out/bin/systemctl-toggle completion bash) \
      --zsh <($out/bin/systemctl-toggle completion zsh) \
      --fish <($out/bin/systemctl-toggle completion fish)
  '';

  meta = {
    description = "Toggle a systemd service unit on or off";
    homepage = "https://github.com/burk3/systemctl-toggle";
    license = lib.licenses.mit;
    mainProgram = "systemctl-toggle";
  };
}
