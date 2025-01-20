from setuptools import find_packages, setup

setup(
    name="{{ package_name }}",
    version="{{ version }}",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    include_package_data=True,
    install_requires=[
        # List your package dependencies here
        # For example:
        # "requests>=2.25.1",
        {{ install_requires }}
    ],
    entry_points={
        "console_scripts": [
            # Add your command line scripts here
            # "your-command=your_package.module:function",
            {{ console_scripts }}
        ],
    },
    python_requires="{{ python_requires }}",
    author="{{ author }}",
    author_email="{{ author_email }}", 
    description="{{ description }}",
    long_description=open("README.md").read(),
    long_description_content_type="text/markdown",
    url="{{ repository_url }}",
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        {{ additional_classifiers }}
    ],
)
