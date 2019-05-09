# Paraphrase Sense-Tagged Sentences (PSTS)

This directory holds the PSTS resource, which contains sentences pertaining to paraphrase 
pairs from PPDB. For example, sentences containing `bug` in its sense as a paraphrase of
`error` include:

- `Report a **bug** .`
- `This **bug** code is normally caused by a parity error in the system memory .`

and sentences containing `bug` in its sense as a paraphrase of `microbe` include:

- `You know, maybe it's that **bug** that's been going around.`
- `We all picked up a little **bug** from India.`

If you use this resource in your work, please cite:

'''
@phdthesis{phdthesis,
  author       = {Anne O'Donnell Cocos}, 
  title        = {Paraphrase-based Models of Lexical Semantics},
  school       = {University of Pennsylvania},
  year         = 2019,
  month        = 5,
}
'''

## Contents

    |-- README.md  -- This file
    |-- src
        |-- psts.py  -- Code to connect to and query mongodb instance
        |-- download_db.sh  -- Command to download psts-small or psts-all dump (run this first)
        |-- build_db_from_dump.sh  -- Code to build mongodb instance (run this second)
        |-- deploy.sh  -- Code to deploy mongodb instance locally (run once built, each time you want to use `psts.py`)
        |-- stop-db.sh -- Code to stop mongodb instance locally
    |-- small
        |-- psts-small.zip -- zipped dump of psts-small (to be downloaded by download_db.sh)
        |-- db/  -- mongodb instance of psts-small (filled after running build_db_from_dump.sh)
    |-- all
        |-- psts-all.zip  -- zipped dump of psts-all (to be downloaded by download_db.sh)
        |-- db/  -- mongodb instance of psts-all  (filled after running build_db_from_dump.sh)

## Sizes

Currently PSTS comes in two sizes:
- `psts-all` (252.0 GB): Contains up to 10k sentences pertaining to each of the PPDB-XXL paraphrases 
having PPDB2.0Score at least 2.0
- `psts-small` (2.2 GB): Contains up to 30 sentences pertaining to the PPDB-XXL paraphrases having 
PPDB2.0Score at least 2.0

## Download and Installation

0.  First you'll need to have MongoDB installed, which you
can do by following the directions for your OS [here](https://docs.mongodb.com/manual/installation/).

1. Download one of the PSTS JSON dump files (`psts-all.zip` or `psts-small.zip`) using
the script `./src/download_db.sh`:
    '''
    ./src/download_db.sh <SIZE>
    '''
where `<SIZE>` is one of `all` or `small`. Warning -- the `all` version is 252 GB compressed. 
If you are just browsing, start with the `small` version.

2. Build the database from the downloaded dump, using the script `./src/build_db_from_dump.sh`:
    '''
    ./src/build_db_from_dump.sh <SIZE>
    '''
where `<SIZE>` is one of `all` or `small`. The whole process should take about 15-20 min for 
the `small` version...significantly larger for `all`.

3. Once the MongoDB instance has been setup in step 2, each time you want to query it using `psts.py` 
you'll need to deploy a local instance of the database. You can do this easily by running:
    '''
    ./src/deploy.sh <SIZE>
    '''
where `<SIZE>` is one of `all` or `small`.

4. The script `psts.py` contains functions for querying the local PSTS MongoDB instance. The
main query function is `PSTS.find()` -- here is an example of its use:

```python
import psts

resource = psts.PSTS('localhost',27017)

result = resource.find('NN', 'bug', 'microbe', n=5, weights='score')
for sent in result:
    print '\t'.join((sent['tokens'], sent['lang'], sent['trans']))

# ulcer bug strongly linked to irregular heartbeat        ar      ميكروب
# how do you keep yourself safe from the flu bug when traveling ? ar      ميكروب
# could have been a bug he got here .     fr      microbe
# has he got this bug ?   fr      microbe
# i mean , if we can get a bug that 's resistant to the virus , this might be worth it .        fr      bactérie
```

## Database Structure

The PSTS resource is stored as a collection of MongoDB documents. For a `(tgt, pp)` 
(target, paraphrase) pair, the available sentences in PSTS are stored with the structure:

```python
{'pos': 'NN',
 'pp1': 'bug',
 'pp2': 'microbe',
 'ppdb2score': 2.51369,
 'pp1_sents': [{'lang': "ar",
                'e_idx': 1,
                's_idx': 1,
                'log_p_f': -14.8315074951,
                'tokens': "ulcer bug strongly linked to irregular heartbeat",
                'score': -1.0,
                'log_pmi': 12.6342829177,
                'log_p_f_e': -2.19722457734,
                'trans': "ميكروب"}, ...],
  'pp2_sents': [{'lang': "fr",
                 'e_idx':  2,
                 's_idx':  2,
                 'log_p_f': -14.5358728955,
                 'tokens': "although the microbe has occasionally caused infections among patients with traumatic injuries , an outbreak in watsonville , california , was the first to spread in a community .",
                 'score': -1.0,
                 'log_pmi': 9.19114915613,
                 'log_p_f_e': -5.34472373936,
                 'trans': "microbe"}, ...],
}
```

Attributes are as follows:
- `pos` : the part of speech of the paraphrase pair
- `pp1` : the source or target, whichever is first alphabetically
- `pp2` : the source or target, whichever is second alphabetically
- `ppdb2score` : the maximum of the ppdbscore of (pp1,pp2) or (pp2,pp1)
- `pp1_sents` : PSTS sentences containing pp1 (target) in its sense as a paraphrase of pp2 (pp)
- `pp2_sents` : PSTS sentences containing pp2 (target) in its sense as a paraphrase of pp1 (pp)

Within the sentence lists, attributes of each dict are:
- `lang` : the language of the translation used to extract the sentence
- `trans` : the translation used to extract the sentence
- `tokens` : the (tokenized) sentence
- `s_idx` : the starting index of the English target word in the tokenized sentence
- `e_idx` : the ending index of the English target word in the tokenized sentence
- `log_pmi` : the PMI of the foreign translation with the pp in the paraphrase pair
- `log_p_f` : the translation probability of the translation
- `log_p_f_e` : the alignment probability between the pp in the paraphrase pair, and the foreign translation
- `score` : the regression model predicted quality score for the sentence (should correlate with how 'characteristic' the sentence is of the shared meaning of the paraphrase pair)
