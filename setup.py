#!/usr/bin/env python3
import pathlib

from setuptools import find_packages, setup

HERE = pathlib.Path(__file__).parent.resolve()

README = (HERE / "README.md").read_text()

tests_require = [
    "docutils",
    "boltons",
    "deepdiff",
    "jsonschema >= 4.18",
    "lxml_html_clean",
    "pre-commit",
    "pytest",
    "pytest-benchmark",
    "requests-html",
    "blinker",
    "prometheus-flask-exporter",
    "ruff",
    "sphinx_click",
    "docker",
]

extras_require = {
    "test": tests_require,
    # These are all optional but nice to have on a real deployment
    "deployment": [
        # Performance
        "ciso8601",
        "bottleneck",
        # The default run.sh and docs use gunicorn+meinheld
        "gunicorn>=22.0.0",
        "setproctitle",
        "gevent",
        # Monitoring
        "blinker",
        "prometheus-flask-exporter",
    ],
}

extras_require["test"].extend(extras_require["deployment"])

setup(
    name="datacube-explorer",
    description="Web-based exploration of Open Data Cube collections",
    long_description=README,
    long_description_content_type="text/markdown",
    use_scm_version=True,
    setup_requires=["setuptools_scm"],
    python_requires=">=3.10",
    url="https://github.com/opendatacube/datacube-explorer",
    author="Geoscience Australia",
    author_email="earth.observation@ga.gov.au",
    license="Apache Software License 2.0",
    packages=find_packages(exclude=("integration_tests",)),
    project_urls={
        "Bug Reports": "https://github.com/opendatacube/datacube-explorer/issues",
        "Source": "https://github.com/opendatacube/datacube-explorer",
    },
    classifiers=[
        "License :: OSI Approved :: Apache Software License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Programming Language :: Python :: 3.12",
        "Programming Language :: Python :: 3.13",
        "Operating System :: OS Independent",
    ],
    include_package_data=True,
    install_requires=[
        "cachetools",
        # Tests fail with "ValueError: I/O operation on closed file" with Click
        # 8.2.0 and later.
        "click<8.2.0",
        "datacube[postgres]>=1.9.0",
        "eodatasets3>=1.9",
        "fiona>=1.10.0",
        "flask",
        "Flask-Caching",
        "flask-cors",
        "flask-themer>=1.4.3",
        "geoalchemy2>=0.8",
        "geographiclib",
        "jinja2",
        "markupsafe",
        "pyorbital",
        "pyproj",
        "pystac",
        "python-dateutil",
        "orjson>=3",
        "sentry-sdk[flask]",
        "shapely",
        "simplekml",
        "sqlalchemy>=1.4",
        "structlog>=20.2.0",
        "pytz",
        "odc-geo",
        "pygeofilter>=0.2.2",
    ],
    tests_require=tests_require,
    extras_require=extras_require,
    entry_points={
        "console_scripts": [
            "cubedash-gen = cubedash.generate:cli",
            "cubedash-view = cubedash.summary.show:cli",
            "cubedash-run = cubedash.run:cli",
            "cubedash-page-test = cubedash.warmup:cli",
        ]
    },
)
