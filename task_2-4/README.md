#2.4. Инструменты Git

1. Полный хеш и комментарий коммита, хеш которого начинается на `aefea`.
```bash
$ git log -p -1 "aefea"
commit aefead2207ef7e2aa5dc81a34aedf0cad4c32545
Author: Alisdair McDiarmid <alisdair@users.noreply.github.com>
Date:   Thu Jun 18 10:29:58 2020 -0400

    Update CHANGELOG.md

diff --git a/CHANGELOG.md b/CHANGELOG.md
index 86d70e3e0..588d807b1 100644
--- a/CHANGELOG.md
+++ b/CHANGELOG.md
@@ -27,6 +27,7 @@ BUG FIXES:
 * backend/s3: Prefer AWS shared configuration over EC2 metadata credentials by default ([#25134](https://github.com/hashicorp/terraform/issues/25134))
 * backend/s3: Prefer ECS credentials over EC2 metadata credentials by default ([#25134](https://github.com/hashicorp/terraform/issues/25134))
 * backend/s3: Remove hardcoded AWS Provider messaging ([#25134](https://github.com/hashicorp/terraform/issues/25134))
+* command: Fix bug with global `-v`/`-version`/`--version` flags introduced in 0.13.0beta2 [GH-25277]
 * command/0.13upgrade: Fix `0.13upgrade` usage help text to include options ([#25127](https://github.com/hashicorp/terraform/issues/25127))
 * command/0.13upgrade: Do not add source for builtin provider ([#25215](https://github.com/hashicorp/terraform/issues/25215))
 * command/apply: Fix bug which caused Terraform to silently exit on Windows when using absolute plan path ([#25233](https://github.com/hashicorp/terraform/issues/25233))
```

2. Какому тегу соответствует коммит `85024d3`
```bash
$ git log -n 1 "85024d3"
commit 85024d3100126de36331c6982bfaac02cdab9e76 (tag: v0.12.23)
Author: tf-release-bot <terraform@hashicorp.com>
Date:   Thu Mar 5 20:56:10 2020 +0000

    v0.12.23
```
tag: v0.12.23

3. Хеши родителей у коммита b8d720.
```bash
$ git log -1 "b8d720"
commit b8d720f8340221f2146e4e4870bf2ee0bc48f2d5
Merge: 56cd7859e 9ea88f22f
Author: Chris Griggs <cgriggs@hashicorp.com>
Date:   Tue Jan 21 17:45:48 2020 -0800

    Merge pull request #23916 from hashicorp/cgriggs01-stable
    
    [Cherrypick] community links
$ git log -1 --oneline --no-abbrev-commit "56cd7859e"
56cd7859e05c36c06b56d013b55a252d0bb7e158 Merge pull request #23857 from hashicorp/cgriggs01-stable
$ git log -1 --oneline --no-abbrev-commit "9ea88f22f"
9ea88f22fc6269854151c571162c5bcf958bee2b add/update community provider listings
```
Коммит создан в результате мержа 2-ух коммитов:
`56cd7859e05c36c06b56d013b55a252d0bb7e158` и `9ea88f22fc6269854151c571162c5bcf958bee2b`

4. Перечислить хеши и комментарии всех коммитов которые были сделаны между тегами v0.12.23 и v0.12.24.
```bash
$ git log --pretty=oneline v0.12.23...v0.12.24
33ff1c03bb960b332be3af2e333462dde88b279e (tag: v0.12.24) v0.12.24
b14b74c4939dcab573326f4e3ee2a62e23e12f89 [Website] vmc provider links
3f235065b9347a758efadc92295b540ee0a5e26e Update CHANGELOG.md
6ae64e247b332925b872447e9ce869657281c2bf registry: Fix panic when server is unreachable
5c619ca1baf2e21a155fcdb4c264cc9e24a2a353 website: Remove links to the getting started guide's old location
06275647e2b53d97d4f0a19a0fec11f6d69820b5 Update CHANGELOG.md
d5f9411f5108260320064349b757f55c09bc4b80 command: Fix bug when using terraform login on Windows
4b6d06cc5dcb78af637bbb19c198faff37a066ed Update CHANGELOG.md
dd01a35078f040ca984cdd349f18d0b67e486c35 Update CHANGELOG.md
225466bc3e5f35baa5d07197bbc079345b77525e Cleanup after v0.12.23 release
```

5. Найти коммит в котором была создана функция func providerSource
```bash
$ git log -S "func providerSource" --oneline --no-abbrev-commit 
5af1e6234ab6da412fb8637393c5a17a1b293663 main: Honor explicit provider_installation CLI config when present
8c928e83589d90a031f811fae52a81be7153e82f main: Consult local directories as potential mirrors of providers
```
Функция создана в коммите `8c928e83589d90a031f811fae52a81be7153e82f`

6. Найти все коммиты в которых была изменена функция `globalPluginDirs`.
```bash
$ git log -S "func globalPluginDirs"
commit 8364383c359a6b738a436d1b7745ccdce178df47
Author: Martin Atkins <mart@degeneration.co.uk>
Date:   Thu Apr 13 18:05:58 2017 -0700

    Push plugin discovery down into command package
    
    Previously we did plugin discovery in the main package, but as we move
    towards versioned plugins we need more information available in order to
    resolve plugins, so we move this responsibility into the command package
    itself.
    
    For the moment this is just preserving the existing behavior as long as
    there are only internal and unversioned plugins present. This is the
    final state for provisioners in 0.10, since we don't want to support
    versioned provisioners yet. For providers this is just a checkpoint along
    the way, since further work is required to apply version constraints from
    configuration and support additional plugin search directories.
    
    The automatic plugin discovery behavior is not desirable for tests because
    we want to mock the plugins there, so we add a new backdoor for the tests
    to use to skip the plugin discovery and just provide their own mock
    implementations. Most of this diff is thus noisy rework of the tests to
    use this new mechanism.
```
Функция `globalPluginDirs` была создана в коммите `8364383c359a6b738a436d1b7745ccdce178df47`
Далее изменений ее не было.

7. Кто автор функции synchronizedWriters
```bash
$ git log -S "func synchronizedWriters" --pretty=format:"%an %ad"
James Bardin Mon Nov 30 18:02:04 2020 -0500
Martin Atkins Wed May 3 16:25:41 2017 -0700
```
Автором был `Martin Atkins`
