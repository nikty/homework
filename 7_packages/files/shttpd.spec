Name:           shttpd
Version:        0.1
Release:        1%{?dist}
Summary:        shttpd is an HTTP server written entirely in POSIX shell script.

License:        MIT
URL:            https://github.com/singpolyma/shttpd
Source0:        shttpd-master.zip
Source1:        shttpd@.service
Source2:        shttpd.socket

Requires:       /bin/sh netcat systemd
BuildArch:      noarch

%description
shttpd is an HTTP server written entirely in POSIX shell script.

%prep
%setup -n shttpd-master


%install
rm -rf %{buildroot}
install -D -m 0755 %{name} %{buildroot}/%{_bindir}/%{name}
mkdir -p %{buildroot}/%{_libdir}/%{name}/modules
install -D -m 0644 modules/* %{buildroot}/%{_libdir}/%{name}/modules/
install -D -m 0644 README %{buildroot}/%{_pkgdocdir}/README
install -D -m 0644 %SOURCE1 %{buildroot}/%{_unitdir}/shttpd@.service
install -D -m 0644 %SOURCE2 %{buildroot}/%{_unitdir}/shttpd.socket


%files
%license COPYING
%{_bindir}/%{name}
%dir %{_libdir}/%{name}
%{_libdir}/%{name}/modules/*
%{_unitdir}/shttpd@.service
%{_unitdir}/shttpd.socket
%doc %{_pkgdocdir}/README

%changelog
* Thu Feb 10 2022 vagrant
- Initial release
