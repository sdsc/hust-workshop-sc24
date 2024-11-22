# tscc_client

## Overview

The wrapper tscc_client is developed around multiple Slurm and our external accounting system’s related commands that can provide information about usage and available balance for Slurm bank accounts. 

## Content

- `tscc_client.sh` - The current implementation of `tscc_client` as a Bash script.
- `tscc_client` - Symbolic link to `tscc_client.sh` to allow implementation to change if/as needed (eg. python) without user documentation needing to be updated.

## Sample Output

### default query, no options

```
tscc_client
```

### query alternate user

```
tscc_client -u <username>
```

### query by Account (all users)

```
tscc_client -A <account>
```

### query by account (only users with usage)

```
tscc_client -A <account> -i
```

### query by regexp in Account description

```
tscc_client -d <description>
```
