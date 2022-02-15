#include <math.h>

#include <fstream>
#include <iostream>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace std;
const int DEBUG = 0;
const int LSBPOLICY = 0;
const int ADVPOLICY = 1;
const int NEGATIVEINFINITE = -2e9;

class CacheBlock {
 public:
  CacheBlock() : NRU(1) {}
  int NRU;
  string address;
};

class Cache {
 public:
  Cache(int set_num, int associativity, int block_bits, int left_bits_num) {
    _block_num_bits = block_bits;
    _set_num = set_num;
    _associativity = associativity;
    _left_bits_num = left_bits_num;
    for (int i = 0; i < set_num; i++) {
      for (int j = 0; j < associativity; j++) {
        store[i].push_back(CacheBlock{});
      }
    }
  }
  map<int, vector<CacheBlock>> store;
  set<int> index_bits_v;

  int _block_num_bits;
  int _set_num;
  int _associativity;
  // trimed address with no offset
  int _left_bits_num;

  int read(string address) {
    int set_no;
    if (LSBPOLICY) set_no = get_set_no_LSB(address, _block_num_bits);
    if (ADVPOLICY) set_no = get_set_no_ADV(address);

    // check whether the cache hit
    for (int i = 0; i < _associativity; i++) {
      CacheBlock &b = store[set_no][i];
      if (b.address == address) return 1;
    }

    // check whether there's block with NRU bit as 0
    for (int i = 0; i < _associativity; i++) {
      CacheBlock &b = store[set_no][i];
      if (b.NRU == 1) {
        b.address = address;
        b.NRU = 0;
        return 0;
      }
    }
    // can't find any NRU == 1, set all NRU as 0
    for (int i = 0; i < _associativity; i++) {
      store[set_no][i].NRU = 1;
    }
    // pick the first one as victim
    store[set_no][0].address = address;
    store[set_no][0].NRU = 0;

    // return 0 for miss
    return 0;
  }
  int get_set_no_LSB(string address, int bit_num) {
    return stoi(address.substr(address.size() - bit_num, bit_num), nullptr, 2);
  }
  // todo :
  int get_set_no_ADV(string address) {
    string no = "";
    for (auto it = index_bits_v.rbegin(); it != index_bits_v.rend(); it++) {
      int adj_id = _left_bits_num - *it - 1;
      int bit = address[adj_id];

      no += bit;
    }
    return stoi(no, nullptr, 2);
  }
};

int main(int argc, char *argv[]) {
  //./project cache1.org reference1.lst index.rpt

  string config, reference, output;
  for (auto i = 0; i < argc; i++) {
    if (i == 1)
      config = argv[i];
    else if (i == 2)
      reference = argv[i];
    else if (i == 3)
      output = argv[i];
  }
  if (DEBUG) {
    cout << "run project" << endl;
    cout << "config file: " << config << endl;
    cout << "reference file: " << reference << endl;
    cout << "output file: " << output << endl;
  }

  ifstream config_fin, reference_fin;
  ofstream fout;
  config_fin.open(config, ios::in);
  reference_fin.open(reference, ios::in);
  fout.open(output, ios::out);

  int address_bit, block_size, cache_sets, associativity;
  // read config
  string title;
  for (int i = 0; i < 4; i++) {
    config_fin >> title;
    if (i == 0)
      config_fin >> address_bit;
    else if (i == 1)
      config_fin >> block_size;
    else if (i == 2)
      config_fin >> cache_sets;
    else if (i == 3)
      config_fin >> associativity;
  }

  //算出 offset bit
  int offset_bits = log2(block_size);

  //算出 block num
  int block_num_bits = log2(cache_sets);

  fout << "Address bits: " << address_bit << endl;
  fout << "Block size: " << block_size << endl;
  fout << "Cache sets: " << cache_sets << endl;
  fout << "Associativity: " << associativity << endl;
  fout << endl;
  fout << "Offset bit count: " << offset_bits << endl;
  fout << "Indexing bit count: " << block_num_bits << endl;
  fout << "Indexing bits:";

  Cache cache(cache_sets, associativity, block_num_bits,
              address_bit - offset_bits);

  if (ADVPOLICY) {
    // For the second part, parse the reference to decide the proper index
    ifstream ref_fin;
    ref_fin.open(reference, ios::in);
    string format, test_name, address, trimed_address;
    ref_fin >> format >> test_name;
    int left_bits = address_bit - offset_bits;
    vector<vector<int>> v(left_bits);
    float cor[left_bits][left_bits];
    float qual[left_bits];

    float line_count = 0;
    while (ref_fin >> address) {
      if (address == ".end") break;
      if (DEBUG) cout << address << endl;
      // trim offset
      trimed_address = address.substr(0, address_bit - offset_bits);

      for (int i = 0; i < left_bits; i++) {
        // cout << "hihi" << i << endl;
        v[i].push_back(trimed_address[left_bits - i - 1] != '0');
      }

      line_count++;
    }

    // count correlation cor
    for (int i = 0; i < left_bits; i++) {
      for (int j = 0; j < left_bits; j++) {
        if (i == j) {
          cor[i][j] = 1;
          continue;
        }
        if (i > j) {
          cor[i][j] = cor[j][i];
          continue;
        }
        float same_num = 0;
        for (int k = 0; k < line_count; k++) {
          if (v[i][k] == v[j][k]) same_num++;
        }
        cor[i][j] = same_num / line_count;
      }
    }

    // print correlation data to check
    // for (int i = 0; i < left_bits; i++) {
    //   for (int j = 0; j < left_bits; j++) {
    //     cout << cor[i][j] << ", ";
    //   }
    //   cout << endl;
    // }
    // cout << endl;
    // cout << endl;

    // count quality
    for (int i = 0; i < left_bits; i++) {
      float zero = 0, one = 0;
      for (int j = 0; j < line_count; j++) {
        if (v[i][j] == 0)
          zero++;
        else
          one++;
      }
      // cout << "zero: " << zero << "one: " << one << endl;
      if (zero >= one)
        qual[i] = one / zero;
      else
        qual[i] = zero / one;
    }

    // cout << endl;
    // iterate to select bits

    for (int i = 0; i < block_num_bits; i++) {
      // print quality:
      for (int i = 0; i < left_bits; i++) cout << qual[i] << ", ";
      cout << endl;

      // set max quality as 0
      int max_idx;
      float max_q = 0;

      for (int j = 0; j < left_bits; j++) {
        if (qual[j] >= max_q) {
          cout << "max is: " << max_q << "current is: " << qual[j] << endl;
          max_idx = j;
          max_q = qual[j];
        }
      }
      cout << "pick: " << max_idx << "qual: " << qual[max_idx] << endl;
      cache.index_bits_v.insert(max_idx);

      // adjust the quality by correlation
      for (int j = 0; j < left_bits; j++) {
        qual[j] *= cor[max_idx][j];
      }

      qual[max_idx] = -1;
    }
    // for (auto i : index_bits_v) cout << i << ", ";
  }

  // 0 1 2 3
  if (LSBPOLICY) {
    for (int i = address_bit - 1; i >= 0; i--) {
      if (i < block_num_bits + offset_bits && i >= offset_bits)
        fout << " " << i;
    }
  } else if (ADVPOLICY) {
    for (auto it = cache.index_bits_v.rbegin(); it != cache.index_bits_v.rend();
         it++) {
      fout << " " << *it + offset_bits;
    }
  }

  fout << endl << endl;

  // read the reference file
  string format, test_name, address, trimed_address;
  reference_fin >> format >> test_name;
  // write the ouput format
  fout << ".benchmark " << test_name << endl;

  int miss = 0;
  while (reference_fin >> address) {
    if (address == ".end") break;
    if (DEBUG) cout << address << endl;
    // trim offset
    int len = address.size();
    trimed_address = address.substr(0, len - offset_bits);

    if (cache.read(trimed_address) == 1)
      fout << address << " hit" << endl;
    else {
      fout << address << " miss" << endl;
      miss++;
    }
  }

  fout << ".end\n" << endl;
  fout << "Total cache miss count: " << miss;

  return 0;
}
