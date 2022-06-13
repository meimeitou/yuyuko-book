+++
title = "Rpmbuild"
date =  2021-04-11T20:29:47+08:00
description= "rpm build"
weight = 5
+++

## 准备

```shell
sudo yum install rpm-build
sudo yum install rpmdevtools
```


## new project

默认的`_topdir`是用户的`<home>/rpmbuild`目录，所以一般到用户的home目录下创建项目。

当然通过修改`_topdir`也能到其它目录创建。

```shell
# 创建目录
rpmdev-setuptree
# or
mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

# 生成 初始spec文件
rpmdev-newspec hello
```

目录结构：

```shell
rpmbuild
|_ BUILD
|_ BUILDROOT
|_ RPMS
|_ SOURCES
|_ SPECS
|_ SRPMS
```

## spec 文件

### 分段

- 定义段
- 构建段
- 安装段

1. 定义

```spec
Name
Version
Release
Summary
License
URL
Source0
Patch0
...
```

2. 构建

```spec
%description
%prep
%build
%install
%check
%files
%changelog
```

3. 安装

```shell
%pre
%post
%preun
%postun
```
### Macros

宏定义

ref: `https://docs.fedoraproject.org/en-US/packaging-guidelines/RPMMacros/`

宏定义查看

```shell
rpm --showrc
# or 宏计算
rpm --eval %dump

# 其它
rpm --eval "%{_topdir}"
```

宏示例：

#### 1. macro: %setup

```shell
cd %{_topdir}/BUILD
rm -rf hello-2.10
gzip -dc %{_topdir}/SOURCES/hello-2.10.tgz | tar -xvvf -
if [ $? -ne 0 ]; then
  exit $?
fi
cd hello-2.10
cd %{_topdir}/BUILD/hello-2.10
chown -R root.root .
chmod -R a+rX,g-w,o-w .
```

#### 2. macro: %configure

等于：

```shell
cd %{_topdir}/BUILD/hello-2.10
./configure
```


一个完整示例：

```spec
%undefine _missing_build_ids_terminate_build

Name:           node_exporter
Version:        1.1.2
Release:        1%{?dist}
Summary:        node expoter install
Summary(zh_CN): node expoter 安装

License:        GPLv3+
URL:            https://sdns.360.cn
Source0:        node_exporter-%{version}.tar.gz

BuildRequires:  gettext  
# Requires(post):     

%description
install node expoter.

%description -l zh_CN
安装node expoter。

# pre build
%prep
%setup -q

%build


%install
rm -rf $RPM_BUILD_ROOT
mkdir -p %{buildroot}/usr/local/bin
mkdir -p %{buildroot}/etc/node_exporter
mkdir -p %{buildroot}/etc/systemd/system
install -m 755 node_exporter  %{buildroot}/usr/local/bin
install -m 644 config.yaml  %{buildroot}/etc/node_exporter
install -m 644 node_exporter.service %{buildroot}/etc/systemd/system

# file install
%files
%defattr(0444,root,root)
%attr(0755,root,root) /usr/local/bin/node_exporter
%attr(0755,root,root) /etc/node_exporter/config.yaml
%attr(0755,root,root) /etc/systemd/system/node_exporter.service

# pre install
%pre
getent group node-exp || groupadd -r node-exp
useradd -G node-exp -s /usr/sbin/nologin -r -N -M -d / node-exp

# post install
%post
systemctl enable node_exporter
systemctl start node_exporter

# pre uninstall
%preun
systemctl stop node_exporter
systemctl disable node_exporter

# post uninstall
%postun
userdel node-exp
groupdel node-exp

%changelog
* Thu Jul 01 2021 The Coon of Ty <TonyYin@360.cn> - 1.0
- Initial version of the package
```

## build

```shell
# 构建
rpmbuild -ba hello.spec
# or
rpmbuild --define "_topdir `pwd`" -v -ba SPECS/hello.spec

# 检查
rpmlint hello.spec
rpmlint hello.spec ../SRPMS/hello* ../RPMS/*/hello*

# 安装
rpm -ivp RPMS/x86_64/hello-2.10-1.el7.x86_64.rpm
# 卸载
rpm -e hello-2.10-1.el7.x86_64
```


# ref


1. `https://rpm-packaging-guide.github.io/`
2. `https://docs.fedoraproject.org/en-US/packaging-guidelines/RPMMacros/`
3. `http://ftp.rpm.org/max-rpm/s1-rpm-build-creating-spec-file.html`
