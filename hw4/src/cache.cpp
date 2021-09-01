#include <iostream>
#include<fstream>

using namespace std;

int main(){

ifstream inFile("trace1.txt", ios::in);

if(!inFile){
 cerr << "Failed opening input.txt." << endl;
}

ofstream outFile("trace1.out", ios::out);

if(!outFile){
 cerr << "Failed opening output.txt." << endl;
}

int cache_size, block_size, associativity, replacement_policy, num_of_block, way, set_num, block_address, index, tag, offset, LRU_index, put_index, tmp, MRU_index;
unsigned int  memory_accesses;

inFile >> cache_size;
inFile >> block_size;
inFile >> associativity;
inFile >> replacement_policy;

num_of_block=cache_size*1024/block_size;


if(associativity==0){
    way=1;
}
else if(associativity==1){
    way=4;
}
else if(associativity==2){
    way=num_of_block;
}

set_num=num_of_block/way;

int cache[way][set_num];
for(int i=0;i<way;i++){
    for(int j=0;j<set_num;j++){
        cache[i][j]=-10;//initialize
    }
}

while(inFile >> hex >> memory_accesses){

    //tag | index | offset
    block_address=memory_accesses/block_size;
    index=block_address%set_num;
    tag=block_address/set_num;

    if(associativity==0){//directed mapped
        if(cache[0][index]!=-10){
            if(cache[0][index]==tag){
                outFile << -1 << endl;//hit
            }
            else{
                outFile << cache[0][index] << endl;
                cache[0][index]=tag;//miss
            }
        }
        else{
            cache[0][index]=tag;
            outFile << -1 << endl;//miss
        }
    }

    else if(associativity==1){//4 way

        if(replacement_policy==0){
            for(int i=0;i<4;i++){
                if(cache[i][index]==tag){
                    outFile << -1 << endl;
                    goto here;
                }
            }
            if(cache[3][index]!=-10){
                outFile << cache[0][index] << endl;
                for(int i=0;i<3;i++){
                    cache[i][index]=cache[i+1][index];//FIFO
                }
                cache[3][index]=tag;
            }
            else{
                put_index=0;
                while(cache[put_index][index]!=-10)
                    put_index++;
                cache[put_index][index]=tag;
                outFile << -1 << endl;//miss
            }


        }
        else if(replacement_policy==1){
            for(int i=0;i<4;i++){
                if(cache[i][index]==tag){
                    outFile << -1 << endl;
                    LRU_index=i;
                    for(int j=i;j<4;j++){
                        cache[j][index]=cache[j+1][index];
                    }
                    goto here;
                }
            }
            if(cache[3][index]!=-10){
                outFile << cache[0][index] << endl;
                for(int i=0;i<3;i++){
                    cache[i][index]=cache[i+1][index];
                }
                cache[3][index]=tag;
            }
            else{
                put_index=0;
                while(cache[put_index][index]!=-10)
                    put_index++;
                cache[put_index][index]=tag;
                outFile << -1 << endl;//miss
            }
        }
        else if(replacement_policy==2){
             for(int i=0;i<4;i++){
                    if(cache[i][index]==tag){
                        outFile << -1 << endl;
                        MRU_index=i;
                        for(int j=MRU_index;j<3;j++){
                            cache[j][index]=cache[j+1][index];
                        }
                        if(cache[3][index]!=-10)
                            cache[3][index]=tag;
                    else{
                            put_index=0;
                            while(cache[put_index][index]!=-10)
                                put_index++;
                            cache[put_index][index]=tag;
                        }
                        goto here;
                    }
                }
            if(cache[3][index]!=-10){
                outFile << cache[3][index] << endl;//MRU
                cache[3][index]=tag;
            }
            else{
                put_index=0;
                while(cache[put_index][index]!=-10)
                    put_index++;
                cache[put_index][index]=tag;
                outFile << -1 << endl;//miss
            }
        }
    }

    else if(associativity==2){//fully
        if(replacement_policy==0){
            for(int i=0;i<num_of_block;i++){
                if(cache[i][index]==tag){
                    outFile << -1 << endl;
                    goto here;
                }
            }
            if(cache[num_of_block-1][index]!=-10){
                outFile << cache[0][index] << endl;
                for(int i=0;i<num_of_block-1;i++){
                    cache[i][index]=cache[i+1][index];//FIFO
                }
                cache[num_of_block-1][index]=tag;
            }
            else{
                put_index=0;
                while(cache[put_index][index]!=-10)
                    put_index++;
                cache[put_index][index]=tag;
                outFile << -1 << endl;//miss
            }
        }
        else if(replacement_policy==1){

            for(int i=0;i<num_of_block;i++){
                if(cache[i][index]==tag){
                    outFile << -1 << endl;
                    LRU_index=i;
                    for(int j=LRU_index;j<num_of_block-1;j++){
                        cache[j][index]=cache[j+1][index];
                    }
                    if(cache[num_of_block-1][index]!=-10)
                        cache[num_of_block-1][index]=tag;
                    else{
                        put_index=0;
                        while(cache[put_index][index]!=-10)
                            put_index++;
                        cache[put_index][index]=tag;
                    }
                    goto here;
                }
            }
            if(cache[num_of_block-1][index]!=-10){
                outFile << cache[0][index] << endl;
                for(int i=0;i<num_of_block-1;i++){
                    cache[i][index]=cache[i+1][index];
                }
                cache[num_of_block-1][index]=tag;
            }
            else{
                put_index=0;
                while(cache[put_index][index]!=-10)
                    put_index++;
                cache[put_index][index]=tag;
                outFile << -1 << endl;//miss
            }
        }
        else if(replacement_policy==2){
                            for(int i=0;i<num_of_block;i++){
                    if(cache[i][index]==tag){
                        outFile << -1 << endl;
                        MRU_index=i;
                        for(int j=MRU_index;j<num_of_block-1;j++){
                            cache[j][index]=cache[j+1][index];
                        }
                        if(cache[num_of_block-1][index]!=-10)
                            cache[num_of_block-1][index]=tag;
                        else{
                            put_index=0;
                            while(cache[put_index][index]!=-10)
                                put_index++;
                            cache[put_index][index]=tag;
                        }
                        goto here;
                    }
                }
            if(cache[num_of_block-1][index]!=-10){
                outFile << cache[num_of_block-1][index] << endl;//MRU
                cache[num_of_block-1][index]=tag;
            }
            else{
                put_index=0;
                while(cache[put_index][index]!=-10)
                    put_index++;
                cache[put_index][index]=tag;
                outFile << -1 << endl;//miss
            }
        }
    }
    here:;

}


}
