# Answer to the question: "is it possible to do Python development in NixOs?"
Yes.

### Working example

```bash
# this repo
git clone https://github.com/carrascomj/isitpossibletodopythondevelopmentinnixos.git nixes
# a difficult package to install
git clone https://github.com/ginkgobioworks/geckopy.git
cp nixes/.envrc nixes/shell.nix 
cd geckopy
# if you are using nix-direnv
direnv allow
# downgrade cobra (unrelated to nix)
pip install --upgrade cobra==0.22
# this should not return any errors
python -c "import geckopy"
```

### The path til here
I adapted the `shell.nix` from [this discussion](https://discourse.nixos.org/t/proper-setup-for-python-development-with-nix-and-vs-code/19011/2). The adaptation was such the import was done from a global nixpkgs (since I am using NixOs).

```python
direnv allow
```

This workflow uses something called [autopatchelf](https://github.com/svanderburg/nix-patchtools) so that the dependencies are bound to the libraries that provide their needs, exactly how they expect them (for a normal Linux distribution). However, 2 libraries could not be found:

```
error: auto-patchelf could not satisfy dependency libz.so.1 wanted by venv/lib/python3.9/site-packages/l
ibsbml/_libsbml.cpython-39-x86_64-linux-gnu.so
error: auto-patchelf could not satisfy dependency libz.so.1 wanted by venv/lib/python3.9/site-packages/n
umpy.libs/libgfortran-040039e1.so.5.0.0
```

And libexpat. Thus, I added them to `buildInputs`:

```python
# ...
buildInputs = [
    # ...
    expat
    libz
]
# ...
```

And that worked! Only that cobrapy should be pinned to 0.22 

```bash
python -c "import geckopy"
```

```
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "/home/d3fault/geckopy/geckopy/__init__.py", line 15, in <module>
    from geckopy import experimental, io
  File "/home/d3fault/geckopy/geckopy/experimental/__init__.py", line 15, in <module>
    from geckopy.experimental import molecular_weights, relaxation
  File "/home/d3fault/geckopy/geckopy/experimental/molecular_weights.py", line 27, in <module>
    from geckopy.model import Model
  File "/home/d3fault/geckopy/geckopy/model.py", line 24, in <module>
    import cobra
  File "/home/d3fault/geckopy/venv/lib/python3.9/site-packages/cobra/__init__.py", line 17, in <module>
    from cobra import io
  File "/home/d3fault/geckopy/venv/lib/python3.9/site-packages/cobra/io/__init__.py", line 9, in <module>
    from cobra.io.web import AbstractModelRepository, BiGGModels, BioModels, load_model
  File "/home/d3fault/geckopy/venv/lib/python3.9/site-packages/cobra/io/web/__init__.py", line 7, in <module>
    from .load import load_model
  File "/home/d3fault/geckopy/venv/lib/python3.9/site-packages/cobra/io/web/load.py", line 31, in <module>
    Cobrapy(),
  File "/home/d3fault/geckopy/venv/lib/python3.9/site-packages/cobra/io/web/cobrapy_repository.py", line 36, in __init__
    super().__init__(url="file:////", **kwargs)
  File "/home/d3fault/geckopy/venv/lib/python3.9/site-packages/cobra/io/web/abstract_model_repository.py", line 55, in __init__
    self._url = httpx.URL(url=url)
  File "/home/d3fault/geckopy/venv/lib/python3.9/site-packages/httpx/_urls.py", line 113, in __init__
    self._uri_reference = urlparse(url, **kwargs)
  File "/home/d3fault/geckopy/venv/lib/python3.9/site-packages/httpx/_urlparse.py", line 252, in urlparse
    validate_path(path, has_scheme=has_scheme, has_authority=has_authority)
  File "/home/d3fault/geckopy/venv/lib/python3.9/site-packages/httpx/_urlparse.py", line 376, in validate_path
    raise InvalidURL(
httpx.InvalidURL: URLs with no authority component cannot have a path starting with '//'
```


Downgrading _actually_ worked:

```
pip install cobra==0.22 --upgrade
python -c "import geckopy"
```

For an LSP, pyright can be added to `buildInputs`, for instance.

