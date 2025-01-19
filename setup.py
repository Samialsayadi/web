from setuptools import find_packages, setup

setup(
    name="your_package_name",
    version="0.1.0",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    include_package_data=True,
    install_requires=[
        # List your package dependencies here
        # For example:
        # "requests>=2.25.1",
    ],
    entry_points={
        "console_scripts": [
            # Add your command line scripts here
            # "your-command=your_package.module:function",
        ],
    },
    python_requires=">=3.6",
    author="Your Name",
    author_email="your.email@example.com", 
    description="A short description of your package",
    long_description=open("README.md").read(),
    long_description_content_type="text/markdown",
    url="https://github.com/username/repository",
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
    ],
)
