'''
psts.py

Code for connecting to and querying PSTS MongoDB instance

Note: To use this code, you need to already have a PSTS MongoDB instance up and running,
which you can do by calling the following from the command line:

nohup numactl --interleave=all mongod --dbpath small/db --bind_ip_all &

'''

import os, sys
import pymongo
from operator import itemgetter

class PSTS():
    def __init__(self, dbhost='localhost', dbport=27017):
        '''
        Initializes PSTS from a running MongoDB instance. Note you must deploy the local
        MongoDb instance first.
        :param: dbhost: string
        :param: dbport: int
        '''
        client = pymongo.MongoClient(dbhost, dbport)
        
        self.db = client.psts_db
        self.collection = self.db.psts
        
    def find(self, pos, tgt, pp, n=30, weights='log_pmi', lang=None):
        '''
        Query PSTS
        :param: pos: string
        :param: tgt: string
        :param: pp: string
        :param (optional) n: int; max number of sentences to return
        :param (optional) weights: string (one of 'log_pmi','score','log_p_f','log_p_f_e')
        :param (optional) lang: string (return only sentences extracted via this language)
        
        :returns: list of dict JSON elements with the following keys:
          - 'tokens' : string, tokenized sentence
          - 's_idx': int, index of start of query term in tokens
          - 'e_idx': int, index of end of query term in tokens
          - 'lang': str, language of translation used to retrieve sentence
          - 'trans': str, translation used to retrieve sentence
          - 'log_pmi': float, PMI of trans and pp term; log_pmi(pp, trans) = log_p(trans|pp) - log_p(trans)
          - 'log_p_f': float, translation probability; log_p(trans)
          - 'log_p_f_e': float, alignment probability for trans given pp; log_p(trans|pp)
        '''
        pp1, pp2 = sorted([tgt, pp])
        if tgt < pp:
            side = 'pp1'
        else:
            side = 'pp2'
        query = {'pos': pos,
                 'pp1': pp1,
                 'pp2': pp2}
        results = [x for x in self.collection.find(query)]
        if len(results) == 0:
            sys.stderr.write('No results found\n')
            return []
        result = results[0]
        
        sents = result['%s_sents' % side]
        if lang is not None:
            sents = [s for s in sents if s['lang']==lang]
        
        sents_sort = sorted(sents, 
                            key=itemgetter(weights), 
                            reverse=True)
        return sents_sort[:n]
        

        