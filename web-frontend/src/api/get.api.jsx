export const getItem = async()=>{
    try{
        const server =`${import.meta.env.VITE_SERVER_URL}/getItem`
        const response = await fetch(server,{
            method:"GET",
            credentials:"include",
        })
        
        if(!response){
            const res = await response.json()
            throw new Error(res.message)
        }
        const data = await response.json()
        return data

    }catch(err){
        throw err;
    }
}

export const getOrders = async(status)=>{
    try{
        const SOCKET_URL = import.meta.env.VITE_SERVER_URL;
        // const socket = io(SOCKET_URL);
        const response = await fetch(`${SOCKET_URL}/orders/${status}`,{
            method:"GET",
            credentials:"include",
        })
        
        if(!response){
            const res = await response.json()
            throw new Error(res.message)
        }
        const data = await response.json()
        return data

    }catch(err){
        throw err;
    }
}

export const getAdmin = async (data) =>{
    try{
        let server = `${import.meta.env.VITE_SERVER_URL}/getAdmin`
        const response = await fetch(server,{
            method:"GET",
            credentials:"include",
        })

        if(!response.ok){
            const res = await response.json();
            throw new Error(res.message)
        }
        const res = await response.json();
        return res

    }catch(err){
        throw err;
    }
}