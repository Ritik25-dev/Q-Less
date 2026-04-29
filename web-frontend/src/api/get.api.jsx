export const getItem = async()=>{
    try{
        const server =`${import.meta.env.VITE_SERVER_URL}/getItem`
        const response = await fetch(server)
        
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