Take aways:
    - Pay attention to asserts/requires and their conditions as they can be used to grief users
    - When you inherit contracts make sure you know what you are inheriting...
    - Don't expect people to use contracts like you intend them to, (here, the creator assumed users would only use depositTokens and not the transfer/transferFrom)
    - Just because you use the "right" libraries, it does not guarentee that your contract is safe or bug free