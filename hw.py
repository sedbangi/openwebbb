# https://decert.me/challenge/45779e03-7905-469e-822e-3ec3746d9ece
# chenyuqing

import hashlib
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.asymmetric import padding
from cryptography.hazmat.primitives import serialization
from cryptography.exceptions import InvalidSignature

# 生成RSA密钥对
def generate_rsa_keypair():
    private_key = rsa.generate_private_key(
        public_exponent=65537,
        key_size=2048,
    )
    public_key = private_key.public_key()
    
    return private_key, public_key

# 获取哈希值 (SHA-256)
def hash_nickname_nonce(nickname, nonce):
    data = f"{nickname}{nonce}".encode('utf-8')
    return hashlib.sha256(data).hexdigest()

# 找到符合条件的哈希值 (哈希值以4个0开头)
def find_valid_nonce(nickname):
    nonce = 0
    while True:
        hash_value = hash_nickname_nonce(nickname, nonce)
        if hash_value.startswith("0000"):  # POW: 哈希值以4个0开头
            return nonce, hash_value
        nonce += 1

# 使用私钥对数据进行签名
def sign_with_private_key(private_key, message):
    signature = private_key.sign(
        message,
        padding.PSS(
            mgf=padding.MGF1(hashes.SHA256()),
            salt_length=padding.PSS.MAX_LENGTH
        ),
        hashes.SHA256()
    )
    return signature

# 使用公钥验证签名
def verify_with_public_key(public_key, message, signature):
    try:
        public_key.verify(
            signature,
            message,
            padding.PSS(
                mgf=padding.MGF1(hashes.SHA256()),
                salt_length=padding.PSS.MAX_LENGTH
            ),
            hashes.SHA256()
        )
        return True
    except InvalidSignature:
        return False

# 保存私钥
def save_private_key_to_file(private_key, filename):
    pem = private_key.private_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PrivateFormat.TraditionalOpenSSL,
        encryption_algorithm=serialization.NoEncryption()
    )
    with open(filename, 'wb') as f:
        f.write(pem)

# 保存公钥
def save_public_key_to_file(public_key, filename):
    pem = public_key.public_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PublicFormat.SubjectPublicKeyInfo
    )
    with open(filename, 'wb') as f:
        f.write(pem)

# 主函数
def main():
    nickname = "chenyuqing"
    
    # 1. 生成公私钥对
    private_key, public_key = generate_rsa_keypair()

    # 2. 找到符合POW条件的nonce
    nonce, valid_hash = find_valid_nonce(nickname)
    print(f"找到的有效 nonce: {nonce}")
    print(f"哈希值: {valid_hash}")
    
    # 3. 使用私钥对有效的“昵称+nonce”进行签名
    message = f"{nickname}{nonce}".encode('utf-8')
    signature = sign_with_private_key(private_key, message)
    print("签名成功！")
    
    # 4. 使用公钥验证签名
    is_valid = verify_with_public_key(public_key, message, signature)
    if is_valid:
        print("签名验证成功！")
    else:
        print("签名验证失败！")
    
    保存密钥对
    save_private_key_to_file(private_key, "private_key.pem")
    save_public_key_to_file(public_key, "public_key.pem")
    print("密钥对已保存到文件。")

if __name__ == "__main__":
    main()
